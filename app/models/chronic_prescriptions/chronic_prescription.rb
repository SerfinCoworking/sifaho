class ChronicPrescription < ApplicationRecord
  include PgSearch::Model

  enum status: { pendiente: 0, dispensada: 1, dispensada_parcial: 2, vencida: 3 }

  # Relaciones
  belongs_to :professional
  belongs_to :patient
  belongs_to :provider_sector, class_name: 'Sector', optional: true
  belongs_to :establishment

  has_many :chronic_dispensations, dependent: :destroy, inverse_of: 'chronic_prescription'
  has_many :chronic_prescription_products, through: :chronic_dispensations
  has_many :original_chronic_prescription_products, dependent: :destroy, inverse_of: 'chronic_prescription'
  has_many :products, through: :chronic_prescription_products
  has_many :movements, class_name: 'ChronicPrescriptionMovement'

  # Validaciones
  validates_presence_of :patient_id, :professional_id, :date_prescribed, :remit_code
  validates_associated :original_chronic_prescription_products
  validates_uniqueness_of :remit_code
  validate :presence_of_products_into_the_order

  # Atributos anidados
  accepts_nested_attributes_for :original_chronic_prescription_products,
                                allow_destroy: true

  delegate :fullname, :last_name, :dni, :age_string, to: :patient, prefix: :patient
  delegate :qualifications, :fullname, to: :professional, prefix: :professional

  filterrific(
    default_filter_params: { sorted_by: 'updated_at_desc' },
    available_filters: %i[search_by_remit_code search_by_professional search_by_patient sorted_by date_prescribed_since
                          for_statuses]
  )

  pg_search_scope :search_by_remit_code,
                  against: :remit_code,
                  using: { tsearch: { prefix: true }, trigram: {} }, # Buscar coincidencia en cualquier parte del string
                  ignoring: :accents # Ignorar tildes.

  pg_search_scope :search_by_professional,
                  associated_against: { professional: %i[last_name first_name] },
                  using: { tsearch: { prefix:  true } }, # Buscar coincidencia desde las primeras letras.
                  ignoring: :accents # Ignorar tildes.

  pg_search_scope :search_by_patient,
                  associated_against: { patient: %i[last_name first_name dni] },
                  using: { tsearch: { prefix: true } }, # Buscar coincidencia desde las primeras letras.
                  ignoring: :accents # Ignorar tildes.

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = sort_option =~ /desc$/ ? 'desc' : 'asc'
    case sort_option.to_s
    when /^updated_at_/s
      # Ordenamiento por fecha de modificacion en la BD
      order("chronic_prescriptions.updated_at #{direction}")
    when /^created_at_/s
      # Ordenamiento por fecha de creacion en la BD
      order("chronic_prescriptions.created_at #{direction}")
    when /^medico_/
      # Ordenamiento por nombre de droga
      order("professionals.last_name #{direction}").joins(:professional)
    when /^paciente_/
      # Ordenamiento por marca de medicamento
      order("patients.last_name #{direction}").joins(:patient)
    when /^estado_/
      # Ordenamiento por nombre de estado
      order("chronic_prescriptions.status #{direction}")
    when /^productos_/
      left_joins(:original_chronic_prescription_products)
      .group(:id)
      .reorder("COUNT(original_chronic_prescription_products.id) #{direction}")
    when /^movimientos_/
      left_joins(:movements)
      .group(:id)
      .reorder("COUNT(chronic_prescription_movements.id) #{direction}")
    when /^recetada_/
      # Ordenamiento por la fecha de recepcion
      order("chronic_prescriptions.date_prescribed #{direction}")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  # Método para establecer las opciones del select sorted_by
  # Es llamado por el controlador como parte de `initialize_filterrific`.
  def self.options_for_sorted_by
    [
      ['Modificación (nueva primero)', 'updated_at_desc'],
      ['Modificación (antigua primero)', 'updated_at_asc'],
      ['Creación (nueva primero)', 'created_at_desc'],
      ['Creación (antigua primero)', 'created_at_asc'],
      ['Medico (a-z)', 'medico_asc'],
      ['Medico (z-a)', 'medico_desc'],
      ['Paciente (a-z)', 'paciente_asc'],
      ['Estado (a-z)', 'estado_asc'],
      ['Productos (mayor primero)', 'productos_desc'],
      ['Productos (menor primero)', 'productos_asc'],
      ['Movimientos (mayor primero)', 'movimientos_desc'],
      ['Movimientos (menor primero)', 'movimientos_asc'],
      ['Fecha recetada (nueva primero)', 'recetada_asc'],
      ['Fecha recetada (antigua primero)', 'recetada_desc'],
    ]
  end

  def self.options_for_statuses
    [
      ['Pendiente', 'pendiente', 'secondary'],
      ['Dispensada', 'dispensada', 'success'],
      ['Dispensada parcial', 'dispensada_parcial', 'primary'],
      ['Vencida', 'vencida', 'danger']
    ]
  end 

  def self.last_week
    where("date_prescribed >= :last_week", { last_week: 1.weeks.ago.midnight })
  end

  # Prescripciones prescritas desde una fecha
  scope :date_prescribed_since, lambda { |reference_time|
    where('chronic_prescriptions.date_prescribed >= ?', reference_time)
  }

  scope :with_establishment, lambda { |a_establishment|
    where('chronic_prescriptions.establishment_id = ?', a_establishment)
  }

  scope :search_by_status, lambda { |status|
    where('chronic_prescriptions.status = ?', status)
  }

  scope :for_statuses, ->(values) do
    return all if values.blank?

    where(status: statuses.values_at(*Array(values)))
  end

  def create_notification(of_user, action_type)
    ChronicPrescriptionMovement.create(user: of_user, chronic_prescription: self, action: action_type, sector: of_user.sector)
    (of_user.sector.users.uniq - [of_user]).each do |user|
      @not = Notification.where( actor: of_user, user: user, target: self, notify_type: "cronica", action_type: action_type, actor_sector: of_user.sector ).first_or_create
      @not.updated_at = DateTime.now
      @not.read_at = nil
      @not.save
    end
  end

  # Actualiza el estado de: ChronicPrescription a "dispensada" y si se completo el ciclo de la receta
  # se actualiza el estado de la receta a "dispensada"
  def dispense_by
    # dispensacion completa: cambio de estado a "dispensada"
    if sum_request_quantity <= sum_delivery_quantity
      self.dispensada!
    end
  end
    
  def return_dispense_by(a_user)
    # dispensacion incompleta con previo estado "dispensada": cambio de estado a "dispensada_parcial"
    update_status
    # if sum_request_quantity > sum_delivery_quantity && self.dispensada?
    #   self.dispensada_parcial!
    # elsif self.chronic_dispensations.count == 0 # && self.dispensada_parcial?
    #   self.pendiente!
    # end

    self.create_notification(a_user, "retornó una dispensación")
  end

  # Returns the name of the efetor who deliver the products
  def origin_name
    self.professional.full_info
  end

  # Returns the name of the efetor who receive the products
  def destiny_name
    self.patient.dni.to_s+" "+self.patient.fullname
  end

  # Return the i18n model name
  def human_name
    self.class.model_name.human
  end

  # Update status prescription based on expiry date and delivered quantity
  def update_status
    if !vencida? && Date.today > self.expiry_date
      vencida!
    elsif (sum_request_quantity <= sum_delivery_quantity) || !any_product_without_dispensing?
      dispensada!
    elsif any_product_without_dispensing? && chronic_dispensations.count > 0
      dispensada_parcial!
    elsif chronic_dispensations.count == 0
      pendiente!
    end
  end
  
  # Return true if all products are 'Terminado' or 'Terminado manual'
  def any_product_without_dispensing?
    return self.original_chronic_prescription_products.for_treatment_statuses(['pendiente']).present?
  end

  # Finish chronic prescription if there any product without dispense
  def finish_by(a_user)
    raise ArgumentError, 'Tratamientos pendientes' if any_product_without_dispensing?
    dispensada!
    create_notification(a_user, 'finalizó la receta')
  end
  
  private
  
  def presence_of_products_into_the_order
    if self.original_chronic_prescription_products.size == 0
      errors.add(:presence_of_products_into_the_order, "Debe agregar almenos 1 producto")
    end
  end

  # Get total requested quantity of original products
  def sum_request_quantity
    original_chronic_prescription_products.sum(:total_request_quantity)
  end

  # Get total delivered quantity of original products
  def sum_delivery_quantity
    original_chronic_prescription_products.sum(:total_delivered_quantity)
  end

end
