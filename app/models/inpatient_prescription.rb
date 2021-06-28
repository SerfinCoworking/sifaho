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
  # belongs_to :bed
  belongs_to :prescribed_by, class_name: 'User'

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
  validates :prescribed_by, presence: true
  validates :patient, presence: true
  validates :remit_code, uniqueness: true

  # Atributos anidados
  accepts_nested_attributes_for :order_products,
                                reject_if: proc { |attributes| attributes['product_id'].blank? },
                                allow_destroy: true
  accepts_nested_attributes_for :parent_order_products,
                                reject_if: proc { |attributes| attributes['product_id'].blank? },
                                allow_destroy: true

  delegate :fullname, :last_name, :dni, :age_string, to: :patient, prefix: :patient

  before_create :set_defaults

  filterrific(
    default_filter_params: { sorted_by: 'updated_at_desc' },
    available_filters: [
      :search_by_patient_id,
      :sorted_by
    ]
  )

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^updated_at_/s
      # Ordenamiento por fecha de modificación en la BD
      reorder("inpatient_prescriptions.updated_at #{ direction }")
    when /^created_at_/s
      # Ordenamiento por fecha de creación en la BD
      reorder("inpatient_prescriptions.created_at #{ direction }")
    when /^medico_/
      # Ordenamiento por nombre de droga
      reorder("LOWER(professionals.last_name) #{ direction }").joins(:professional)
    when /^paciente_/
      # Ordenamiento por marca de medicamento
      reorder("LOWER(patients.last_name) #{ direction }").joins(:patient)
    when /^estado_/
      # Ordenamiento por nombre de estado
      reorder("inpatient_prescriptions.status #{ direction }")
    when /^recetada_/
      # Ordenamiento por la fecha de recepción
      reorder("inpatient_prescriptions.date_prescribed #{ direction }")
    when /^creado_/
      # Ordenamiento por la fecha de recepción
      reorder("inpatient_prescriptions.created_at #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  # Prescripciones prescritas
  scope :search_by_patient_id, lambda { |patient_id|
    where('inpatient_prescriptions.patient_id = ?', patient_id)
  }

  def create_notification(of_user, action_type, order_product = nil)
    InpatientPrescriptionMovement.create(user: of_user, order: self, order_product: order_product,
                                         action: action_type, sector: of_user.sector)
    (of_user.sector.users.uniq - [of_user]).each do |user|
      @not = Notification.where(actor: of_user, user: user, target: self, notify_type: 'internación',
                                action_type: action_type, actor_sector: of_user.sector).first_or_create
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
    
    # self.professional.full_info
  end

  # Returns the name of the efetor who receive the products
  def destiny_name
    self.patient.dni.to_s+" "+self.patient.fullname
  end

  # Return the i18n model name
  def human_name
    self.class.model_name.human
  end

  private

  def set_defaults
    self.remit_code = "IN#{DateTime.now.to_s(:number)}"
    self.status = 'pendiente'
  end
end