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
  has_many :movements, class_name: 'InpatientPrescriptionMovement', foreign_key: "order_id"
  has_many :order_products, dependent: :destroy, class_name: 'InpatientPrescriptionProduct', foreign_key: "inpatient_prescription_id", inverse_of: 'inpatient_prescription'
  has_many :in_pre_prod_lot_stocks, through: :order_products, inverse_of: 'inpatient_prescription'
  has_many :lot_stocks, :through => :order_products
  has_many :lots, :through => :lot_stocks
  has_many :products, :through => :order_products  
  has_many :comments, class_name: "InpatientPrescriptionComment", foreign_key: "order_id", dependent: :destroy

  # Validaciones
  validates_associated :order_products
  validates :professional, presence: true
  validates :patient, presence: true
  validates :remit_code, presence: true, uniqueness: true
  # validate :is_the_prescriptor?

  # Atributos anidados
  accepts_nested_attributes_for :order_products,
    reject_if: proc { |attributes| attributes['product_id'].blank? },
    :allow_destroy => true

  delegate :fullname, :last_name, :dni, :age_string, to: :patient, prefix: :patient
  delegate :enrollment, :fullname, to: :professional, prefix: :professional


  def create_notification(of_user, action_type, order_product = nil)
    InpatientPrescriptionMovement.create(user: of_user, order: self, order_product: order_product, action: action_type, sector: of_user.sector)
    (of_user.sector.users.uniq - [of_user]).each do |user|
      @not = Notification.where( actor: of_user, user: user, target: self, notify_type: "internación", action_type: action_type, actor_sector: of_user.sector ).first_or_create
      @not.updated_at = DateTime.now
      @not.read_at = nil
      @not.save
    end
  end

  private 

  # def is_the_prescriptor?
  #   self.professional_id == self.prescribed_by.professional_id 
  # end
end
