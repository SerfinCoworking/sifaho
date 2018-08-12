class Prescription < ApplicationRecord
  include PgSearch

  # Estados
  enum status: { pendiente: 0, dispensada: 1 }

  # Relaciones
  belongs_to :professional
  belongs_to :patient
  has_many :quantity_supply_requests, :as => :quantifiable, dependent: :destroy, inverse_of: :quantifiable
  has_many :supplies, -> { with_deleted }, :through => :quantity_supply_requests
  has_many :quantity_supply_lots, :as => :quantifiable, dependent: :destroy, inverse_of: :quantifiable
  has_many :sector_supply_lots, -> { with_deleted }, :through => :quantity_supply_lots

  # Validaciones
  validates_presence_of :patient
  validates_presence_of :professional
  validates_presence_of :prescribed_date
  validates_presence_of :expiry_date
  validates_presence_of :quantity_supply_requests
  validates_associated :quantity_supply_requests
  validates_associated :supplies
  validates_associated :quantity_supply_lots
  validates_associated :sector_supply_lots

  # Atributos anidados
  accepts_nested_attributes_for :quantity_supply_requests,
          :reject_if => :all_blank,
          :allow_destroy => true
  accepts_nested_attributes_for :supplies
  accepts_nested_attributes_for :quantity_supply_lots,
          :reject_if => :all_blank,
          :allow_destroy => true
  accepts_nested_attributes_for :sector_supply_lots

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [
      :search_professional_and_patient,
      :search_supply_code,
      :search_supply_name,
      :sorted_by,
      :date_prescribed_since,
      :date_dispensed_since,
    ]
  )

  pg_search_scope :search_professional_and_patient,
  :associated_against => { :professional => :fullname, patient: [:last_name, :first_name] },
  :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_supply_code,
  :associated_against => { :supplies => :id, :sector_supply_lots => :code },
  :using => {:tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_supply_name,
  :associated_against => { :supplies => :name, :sector_supply_lots => :supply_name },
  :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/s
      # Ordenamiento por fecha de creación en la BD
      order("prescriptions.created_at #{ direction }")
    when /^doctor_/
      # Ordenamiento por nombre de droga
      order("LOWER(professionals.first_name) #{ direction }").joins(:professional)
    when /^paciente_/
      # Ordenamiento por marca de medicamento
      order("LOWER(patients.first_name) #{ direction }").joins(:patient)
    when /^estado_/
      # Ordenamiento por nombre de estado
      order("prescriptions.status #{ direction }")
    when /^insumos_solicitados_/
      # Ordenamiento por nombre de insumo
      order("supplies.name #{ direction }").joins(:supplies)
    when /^recetada_/
      # Ordenamiento por la fecha de recepción
      order("prescriptions.prescribed_date #{ direction }")
    when /^recibida_/
      # Ordenamiento por la fecha de recepción
      order("prescriptions.date_received #{ direction }")
    when /^dispensada_/
      # Ordenamiento por la fecha de dispensación
      order("prescriptions.date_dispensed #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  # Prescripciones prescritas desde una fecha
  scope :date_prescribed_since, lambda { |reference_time|
    where('prescriptions.prescribed_date >= ?', reference_time)
  }

  # Prescripciones dispensadas desde una fecha
  scope :date_dispensed_since, lambda { |reference_time|
    where('prescriptions.date_dispensed >= ?', reference_time)
  }

  # Método para establecer las opciones del select input del filtro
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

  #Métodos públicos

  # Cambia estado a dispensado y descuenta la cantidad a los insumos
  def dispense
    if dispensada?
      raise ArgumentError, "Ya se ha entregado esta prescripción"
    else
      if self.quantity_supply_lots.present?
        self.quantity_supply_lots.each do |qsls|
          qsls.decrement
        end
      else
        raise ArgumentError, 'No hay insumos en la prescripción'
      end
      self.date_dispensed = DateTime.now
      self.dispensada!
    end #End dispensada?
  end

  # Label del estado para vista.
  def status_label
    if self.dispensada?; return 'success'; elsif self.pendiente?; return 'default'; end
  end

  # Métodos de clase

  def self.current_day
    where("prescribed_date >= :today", { today: DateTime.now.beginning_of_day })
  end

  def self.current_month
    where("prescribed_date >= :month", { month: DateTime.now.beginning_of_month })
  end
end
