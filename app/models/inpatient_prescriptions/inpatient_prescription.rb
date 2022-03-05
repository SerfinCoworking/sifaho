class InpatientPrescription < ApplicationRecord
  include PgSearch::Model
  include EnumTranslation

  enum status: {
    pending: 0,
    parcialmente_dispensada: 1,
    dispensada: 2,
    finished: 3,
    canceled: 4
  }

  # Relationships
  belongs_to :patient
  belongs_to :prescribed_by, class_name: 'User', optional: true
  belongs_to :bed
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

  # Validations
  validates_associated :order_products
  # validates :prescribed_by, presence: true
  validates :patient, presence: true
  validates :remit_code, uniqueness: true
  validates_presence_of :date_prescribed, :patient_id, :bed_id
  validates_uniqueness_of :date_prescribed, scope: :patient_id, message: 'en uso. El paciente ya tiene una receta.'

  # Atributos anidados
  accepts_nested_attributes_for :order_products,
                                reject_if: proc { |attributes| attributes['product_id'].blank? },
                                allow_destroy: true
  accepts_nested_attributes_for :parent_order_products,
                                reject_if: proc { |attributes| attributes['product_id'].blank? },
                                allow_destroy: true

  # Delegations
  delegate :fullname, :last_name, :dni, :age_string, to: :patient, prefix: :patient
  delegate :bedroom_name, :service_name, to: :bed, prefix: false
  delegate :name, to: :bed, prefix: :bed

  before_validation :set_defaults, on: :create

  filterrific(
    default_filter_params: { sorted_by: 'recetada_desc' },
    available_filters: [
      :search_by_remit_code,
      :date_prescribed_since,
      :for_statuses,
      :search_by_patient_ids,
      :search_by_patient_id,
      :sorted_by
    ]
  )

  pg_search_scope :search_by_remit_code,
                  against: [:remit_code],
                  using: { tsearch: { prefix: true } }, # Buscar coincidencia desde las primeras letras.
                  ignoring: :accents # Ignorar tildes.

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = sort_option =~ /desc$/ ? 'desc' : 'asc'
    case sort_option.to_s
    when /^updated_at_/s
      # Ordenamiento por fecha de modificacion en la BD
      reorder("inpatient_prescriptions.updated_at #{direction}")
    when /^created_at_/s
      # Ordenamiento por fecha de creacion en la BD
      reorder("inpatient_prescriptions.created_at #{direction}")
    when /^paciente_/
      # Ordenamiento por marca de medicamento
      reorder("LOWER(patients.last_name) #{direction}").joins(:patient)
    when /^estado_/
      # Ordenamiento por nombre de estado
      reorder("inpatient_prescriptions.status #{direction}")
    when /^recetada_/
      # Ordenamiento por la fecha de recepcion
      reorder("inpatient_prescriptions.date_prescribed #{direction}")
    when /^creado_/
      # Ordenamiento por la fecha de recepcion
      reorder("inpatient_prescriptions.created_at #{direction}")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  # Prescripciones prescritas
  scope :search_by_patient_id, ->(patient_id) { where('inpatient_prescriptions.patient_id = ?', patient_id) }

  scope :search_by_patient_ids, lambda { |patient_ids|
    left_joins(:patient).where(patient_id: patient_ids)
  }

  # Prescripciones prescritas desde una fecha
  scope :date_prescribed_since, lambda { |reference_time|
    where('inpatient_prescriptions.date_prescribed >= ?', reference_time)
  }

  scope :for_statuses, ->(values) do
    return all if values.blank?

    where(status: statuses.values_at(*Array(values)))
  end

  def self.options_for_status
    [
      ['Pendiente', 'pending', 'secondary'],
      ['Parcialmente dispensada', 'parcialmente_dispensada', 'warning'],
      ['Dispensada', 'dispensada', 'success'],
      ['Terminada', 'finished', 'primary'],
      ['Anulado', 'anulado', 'danger']
    ]
  end

  def self.options_for_sorted_by
    [
      ['Modificación (nueva primero)', 'updated_at_desc'],
      ['Modificación (antigua primero)', 'updated_at_asc'],
      ['Creación (nueva primero)', 'creado_desc'],
      ['Creación (antigua primero)', 'creado_asc'],
      ['Paciente (a-z)', 'paciente_asc'],
      ['Estado (a-z)', 'estado_asc'],
      ['Fecha recetada (nueva primero)', 'recetada_desc'],
      ['Fecha recetada (antigua primero)', 'recetada_asc']
    ]
  end

  def create_notification(of_user, action_type, order_product = nil)
    InpatientPrescriptionMovement.create(user: of_user, order: self, order_product: order_product,
                                         action: action_type, sector: of_user.sector)
    (of_user.sector.users.uniq - [of_user]).each do |user|
      @not = Notification.where(actor: of_user, user: user, target: self, notify_type: 'internacion',
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
    patient.bed.service.name
  end

  # Returns the name of the efetor who receive the products
  def destiny_name
    "#{patient.dni} #{patient.fullname}"
  end

  # Return the i18n model name
  def human_name
    self.class.model_name.human
  end

  # Update status to the specific criteria
  def update_status
    finished! if pending? && Date.today > date_prescribed
  end

  private

  def set_defaults
    self.remit_code = "IN#{DateTime.now.to_s(:number)}"
    self.bed_id = patient.bed_id if patient.bed_id.present?
  end
end
