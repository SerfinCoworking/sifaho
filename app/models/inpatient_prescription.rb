class InpatientPrescription < ApplicationRecord
  include PgSearch

  enum status: {
    pendiente: 0,
    parcialmente_dispensada: 1,
    dispensada: 2,
    anulado: 3
  }
  
  # Relations
  belongs_to :patient
  belongs_to :professional
  # belongs_to :bed
  # belongs_to :prescribed_by, class_name: 'User'
  has_many :movements, class_name: 'InpatientPrescriptionMovement', foreign_key: 'order_id'
  has_many  :order_products, -> { only_children },
            dependent: :destroy,
            class_name: 'InpatientPrescriptionProduct',
            foreign_key: 'inpatient_prescription_id',
            inverse_of: 'order'

  has_many  :parent_order_products, -> { only_parents },
            dependent: :destroy,
            class_name: 'InpatientPrescriptionProduct',
            foreign_key: 'inpatient_prescription_id',
            inverse_of: 'order'

  has_many :products, through: :order_products

  # Validaciones
  validates_associated :order_products
  validates :professional, presence: true
  validates :patient, presence: true
  validates :remit_code, presence: true, uniqueness: true
  # validate :is_the_prescriptor?

  # Atributos anidados
  accepts_nested_attributes_for :order_products,
                                reject_if: proc { |attributes| attributes['product_id'].blank? },
                                allow_destroy: true
  accepts_nested_attributes_for :parent_order_products,
                                reject_if: proc { |attributes| attributes['product_id'].blank? },
                                allow_destroy: true

  delegate :fullname, :last_name, :dni, :age_string, to: :patient, prefix: :patient
  delegate :enrollment, :fullname, to: :professional, prefix: :professional

  after_create :set_parent_products_status
  after_update :set_parent_products_status

  def create_notification(of_user, action_type, order_product = nil)
    InpatientPrescriptionMovement.create(user: of_user, order: self, order_product: order_product, action: action_type, sector: of_user.sector)
    (of_user.sector.users.uniq - [of_user]).each do |user|
      @not = Notification.where( actor: of_user, user: user, target: self, notify_type: "internación", action_type: action_type, actor_sector: of_user.sector ).first_or_create
      @not.updated_at = DateTime.now
      @not.read_at = nil
      @not.save
    end
  end

  # Dispensamos la entrega de medicacion a un paciente en internacion
  # Marcamos "dispensada" parcialmente
  # Luego se llaman los productos que aun no fueron dispensados para decrementar el stock
  def dispensed_by(a_user)
    parent_order_products.sin_proveer.each(&:decrement_stock)
    self.status = parent_order_products.sin_proveer.any? ? 'parcialmente_dispensada' : 'dispensada'
    save!(validate: false)
    notification_type = 'entregó'
    create_notification(a_user, notification_type)
  end

  # Returns the name of the efetor who deliver the products
  def origin_name
    professional.full_info
  end

  # Returns the name of the efetor who receive the products
  def destiny_name
    "#{patient.dni} #{patient.fullname}"
  end

  private

  def set_parent_products_status
    parent_order_products.where(status: nil).each(&:sin_proveer!)
  end
end