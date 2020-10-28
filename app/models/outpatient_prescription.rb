class OutpatientPrescription < ApplicationRecord

  include PgSearch

  # Estados
  enum status: { pendiente: 0, dispensada: 1, vencida: 2 }

  # Relaciones
  belongs_to :professional
  belongs_to :patient
  belongs_to :provider_sector, class_name: 'Sector', optional: true
  belongs_to :establishment

  has_many :outpatient_prescription_products, dependent: :destroy
  has_many :lot_stocks, :through => :outpatient_prescription_products, dependent: :destroy
  has_many :lots, :through => :lot_stocks

  has_many :products,:through => :outpatient_prescription_products
  has_many :movements, class_name: "OutpatientPrescriptionMovement"

  # Validaciones
  validates_presence_of :patient, :professional, :date_prescribed, :remit_code
  validates :outpatient_prescription_products, :presence => {:message => "Debe agregar almenos 1 insumo"}
  validates_associated :outpatient_prescription_products
  validates_uniqueness_of :remit_code

  # Atributos anidados
  accepts_nested_attributes_for :outpatient_prescription_products,
    :allow_destroy => true

  delegate :fullname, :last_name, :dni, :age_string, to: :patient, prefix: :patient
  delegate :enrollment, :fullname, to: :professional, prefix: :professional

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [
      :search_by_professional,
      :search_by_patient,
      :search_by_supply,
      :sorted_by,
      :with_order_type,
      :date_prescribed_since,
    ]
  )

  # SCOPES #--------------------------------------------------------------------

  pg_search_scope :search_by_professional,
  :associated_against => { professional: [ :last_name, :first_name ] },
  :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_by_patient,
  :associated_against => { patient: [ :last_name, :first_name, :dni ] },
  :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_by_supply,
  :associated_against => { supplies: [ :id, :name ] },
  :using => {:tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/s
      # Ordenamiento por fecha de creación en la BD
      order("outpatient_prescriptions.created_at #{ direction }")
    when /^profesional_/
      # Ordenamiento por nombre de droga
      order("LOWER(professionals.first_name) #{ direction }").joins(:professional)
    when /^paciente_/
      # Ordenamiento por marca de medicamento
      order("LOWER(patients.first_name) #{ direction }").joins(:patient)
    when /^estado_/
      # Ordenamiento por nombre de estado
      order("outpatient_prescriptions.status #{ direction }")
    when /^insumos_solicitados_/
      # Ordenamiento por nombre de insumo
      order("supplies.name #{ direction }").joins(:supplies)
    when /^recetada_/
      # Ordenamiento por la fecha de recepción
      order("outpatient_prescriptions.prescribed_date #{ direction }")
    when /^recibida_/
      # Ordenamiento por la fecha de recepción
      order("outpatient_prescriptions.date_received #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  # Prescripciones prescritas desde una fecha
  scope :date_prescribed_since, lambda { |reference_time|
    where('outpatient_prescriptions.prescribed_date >= ?', reference_time)
  }

  scope :with_order_type, lambda { |a_order_type|
    where('outpatient_prescriptions.order_type = ?', a_order_type)
  }

  scope :for_statuses, ->(values) do
    return all if values.blank?

    where(status: statuses.values_at(*Array(values)))
  end

  scope :with_establishment, lambda { |a_establishment|
    where('outpatient_prescriptions.establishment_id = ?', a_establishment)
  }

  # Métodos públicos #----------------------------------------------------------
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

    self.outpatient_prescription_products.each do |iop|
      iop.decrement_stock
    end

    self.save!(validate: false)
    self.create_notification(a_user, "dispensó")
  end

  # Método para retornar pedido a estado anterior
  def return_dispensation(a_user)
    if self.dispensada?
      self.outpatient_prescription_products.each do |opp|
        opp.increment_stock
      end

      self.status = "pendiente"
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

  # Métodos de clase #----------------------------------------------------------
  scope :with_patient_id, lambda { |an_id|
    where(patient_id: [*an_id])
  }

  def self.current_day
    where("prescribed_date >= :today", { today: DateTime.now.beginning_of_day })
  end

  def self.last_week
    where("prescribed_date >= :last_week", { last_week: 1.weeks.ago.midnight })
  end

  def self.current_year
    where("prescribed_date >= :year", { year: DateTime.now.beginning_of_year })
  end

  def self.current_month
    where("prescribed_date >= :month", { month: DateTime.now.beginning_of_month })
  end

  # Método para establecer las opciones del select sorted_by
  # Es llamado por el controlador como parte de `initialize_filterrific`.
  def self.options_for_sorted_by
    [
      ['Creación', 'created_at_asc'],
      ['Doctor (a-z)', 'doctor_asc'],
      ['Paciente (a-z)', 'paciente_asc'],
      ['Estado (a-z)', 'estado_asc'],
      ['Insumos solicitados (a-z)', 'insumos_solicitados_asc'],
      ['Fecha recetada (desc)', 'recetada_desc'],
      ['Fecha recibida (desc)', 'recibida_desc'],
      ['Fecha dispensada (asc)', 'dispensada_asc'],
      ['Cantidad', 'cantidad_asc']
    ]
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

end
