class OutpatientPrescription < ApplicationRecord
  include PgSearch::Model

  # Statuses
  enum status: { pendiente: 0, dispensada: 1, vencida: 2 }

  # Relationships
  belongs_to :professional
  belongs_to :patient
  belongs_to :provider_sector, class_name: 'Sector', optional: true
  belongs_to :establishment

  has_many :outpatient_prescription_products, dependent: :destroy
  has_many :products, through: :outpatient_prescription_products
  has_many :movements, class_name: 'OutpatientPrescriptionMovement'
  has_many :stock_movements, as: :order, dependent: :destroy, inverse_of: :order

  # Validations
  validates_presence_of :patient_id, :professional_id, :date_prescribed, :remit_code
  validates_associated :outpatient_prescription_products
  validates_uniqueness_of :remit_code
  validate :presence_of_products_into_the_order
  validate :date_prescribed_in_range

  # Nested attributes
  accepts_nested_attributes_for :outpatient_prescription_products,
                                allow_destroy: true

  # Delegations
  delegate :fullname, :last_name, :dni, :age_string, to: :patient, prefix: :patient, allow_nil: true
  delegate :qualifications, :fullname, to: :professional, prefix: :professional

  filterrific(
    default_filter_params: { sorted_by: 'updated_at_desc' },
    available_filters: %i[search_by_remit_code search_by_professional search_by_patient sorted_by with_order_type
                          date_prescribed_since for_statuses]
  )

  # SCOPES #--------------------------------------------------------------------

  pg_search_scope :search_by_remit_code,
                  against: [:remit_code],
                  using: { tsearch: { prefix: true }, trigram: {} }, # Buscar coincidencia en cualquier parte del string
                  ignoring: :accents # Ignorar tildes.

  pg_search_scope :search_by_professional,
                  associated_against: { professional: %i[last_name first_name] },
                  using: { tsearch: { prefix: true } }, # Buscar coincidencia desde las primeras letras.
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
      reorder("outpatient_prescriptions.updated_at #{direction}")
    when /^created_at_/s
      # Ordenamiento por fecha de creacion en la BD
      reorder("outpatient_prescriptions.created_at #{direction}")
    when /^medico_/
      # Ordenamiento por nombre de droga
      reorder("LOWER(professionals.last_name) #{direction}").joins(:professional)
    when /^paciente_/
      # Ordenamiento por marca de medicamento
      reorder("LOWER(patients.last_name) #{direction}").joins(:patient)
    when /^estado_/
      # Ordenamiento por nombre de estado
      reorder("outpatient_prescriptions.status #{direction}")
    when /^recetada_/
      # Ordenamiento por la fecha de recepcion
      reorder("outpatient_prescriptions.date_prescribed #{direction}")
    when /^creado_/
      # Ordenamiento por la fecha de recepcion
      reorder("outpatient_prescriptions.created_at #{direction}")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  # Metodo para establecer las opciones del select sorted_by
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

  def self.options_for_status
    [
      ['Pendiente', 'pendiente', 'secondary'],
      ['Dispensada', 'dispensada', 'success'],
      ['Vencida', 'vencida', 'danger']
    ]
  end

  # Prescripciones prescritas desde una fecha
  scope :date_prescribed_since, lambda { |reference_time|
    where('outpatient_prescriptions.date_prescribed >= ?', reference_time)
  }

  scope :with_order_type, lambda { |a_order_type|
    where('outpatient_prescriptions.order_type = ?', a_order_type)
  }

  scope :search_by_status, lambda { |status|
    where('outpatient_prescriptions.status = ?', status)
  }

  scope :for_statuses, ->(values) do
    return all if values.blank?

    where(status: statuses.values_at(*Array(values)))
  end

  scope :with_establishment, lambda { |a_establishment|
    where('outpatient_prescriptions.establishment_id = ?', a_establishment)
  }

  scope :with_patient_id, lambda { |an_id|
    where(patient_id: [*an_id])
  }

  # Metodos públicos #----------------------------------------------------------
  def sum_to?(a_sector)
    if self.dispensada?
      return true unless self.provider_sector == a_sector
    end
  end

  def delivered_with_sector?(a_sector)
    if self.dispensada? || self.dispensada_parcial?
      return self.provider_sector == a_sector
    end
  end

  def professional_fullname
    self.professional.full_name
  end

  # Cambia estado a "dispensada" y descuenta la cantidad a los lotes de insumos
  def dispense_by(a_user)
    if self.expiry_date < Date.today
      raise ArgumentError, "No es posible dispensar recetas vencidas."
    end

    self.outpatient_prescription_products.each do |opp|
      opp.decrement_stock
    end
    self.create_notification(a_user, "dispensó")
  end

  # Método para retornar pedido a estado anterior
  def return_dispensation(a_user)
    if self.dispensada?
      self.status = "pendiente"
      self.outpatient_prescription_products.each do |opp|
        opp.increment_stock
      end
      self.save!(validate: false)
      self.create_notification(a_user, "retornó a un estado anterior")
    else
      raise ArgumentError, "No es posible retornar a un estado anterior"
    end
  end

  # Label del estado para vista.
  def status_label
    if self.dispensada?; return 'success';
    elsif self.pendiente?; return 'default';
    elsif self.vencida?; return 'danger'; end
  end

  def sent_date
    self.dispensed_at
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
  
  # Métodos de clase #----------------------------------------------------------
  def self.current_day
    where("date_prescribed >= :today", { today: DateTime.now.beginning_of_day })
  end

  def self.last_week
    where("date_prescribed >= :last_week", { last_week: 1.weeks.ago.midnight })
  end

  def self.current_year
    where("date_prescribed >= :year", { year: DateTime.now.beginning_of_year })
  end

  def self.current_month
    where("date_prescribed >= :month", { month: DateTime.now.beginning_of_month })
  end

  def create_notification(of_user, action_type)
    OutpatientPrescriptionMovement.create(user: of_user, outpatient_prescription: self, action: action_type, sector: of_user.sector)
    (of_user.sector.users.uniq - [of_user]).each do |user|
      @not = Notification.where( actor: of_user, user: user, target: self, notify_type: "ambulatoria", action_type: action_type, actor_sector: of_user.sector ).first_or_create
      @not.updated_at = DateTime.now
      @not.read_at = nil
      @not.save
    end
  end

  def update_status
    if self.pendiente? && self.date_prescribed < Date.today.months_ago(1)
      self.status = 'vencida'
    end
  end

  private
  def presence_of_products_into_the_order
    if self.outpatient_prescription_products.size == 0
      errors.add(:presence_of_products_into_the_order, "Debe agregar almenos 1 producto")      
    end
  end
  
  def date_prescribed_in_range
    # validamos que la fecha de la prescripcion se encuentre en un rango de menor igual a HOY
    # y HOY - 1 MES atras.
    unless self.date_prescribed >= (Date.today.months_ago(1)) && self.date_prescribed <= Date.today
      errors.add(:date_prescribed_in_range, "Debe seleccionar una fecha válida ")   
    end
  end
end
