class Prescription < ApplicationRecord
  enum status: { pendiente: 0, dispensada: 1 }

  # Relaciones
  belongs_to :professional
  belongs_to :patient
  has_many :quantity_supply_lots, :as => :quantifiable, dependent: :destroy, inverse_of: :quantifiable
  has_many :supply_lots, :through => :quantity_supply_lots

  # Validaciones
  validates_presence_of :patient
  validates_presence_of :professional
  validates_associated :quantity_supply_lots
  validates_associated :supply_lots

  accepts_nested_attributes_for :quantity_supply_lots,
          :reject_if => :all_blank,
          :allow_destroy => true
  accepts_nested_attributes_for :supply_lots

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [
      :sorted_by,
      :search_query,
      :date_received_at,
    ]
  )

  # define ActiveRecord scopes for
  # :search_query, :sorted_by, :date_received_at
  scope :search_query, lambda { |query|
    #Se retorna nil si no hay texto en la query
    return nil  if query.blank?

    # Se pasa a minusculas para busqueda en postgresql
    # Luego se dividen las palabras en claves individuales
    terms = query.downcase.split(/\s+/)

    # Remplaza "*" con "%" para busquedas abiertas con LIKE
    # Agrega '%', remueve los '%' duplicados
    terms = terms.map { |e|
      (e.gsub('*', '%') + '%').gsub(/%+/, '%')
    }

    # Cantidad de condiciones.
    num_or_conds = 4
    where(
      terms.map { |term|
        "((LOWER(professionals.first_name) LIKE ? OR LOWER(patients.first_name) LIKE ?) OR (LOWER(professionals.last_name) LIKE ? OR LOWER(patients.last_name) LIKE ?))"
      }.join(' AND '),
      *terms.map { |e| [e] * num_or_conds }.flatten
    ).joins(:professional, :patient)
  }

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
      order("prescription_statuses.name #{ direction }").joins(:prescription_status)
    when /^insumo_/
      # Ordenamiento por nombre de insumo
      order("supply_lots.supply_name #{ direction }").joins(:supply_lots)
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

  scope :date_received_at, lambda { |reference_time|
    where('prescriptions.date_received >= ?', reference_time)
  }


  # Método para establecer las opciones del select input del filtro
  # Es llamado por el controlador como parte de `initialize_filterrific`.
  def self.options_for_sorted_by
    [
      ['Creación', 'created_at_asc'],
      ['Doctor (a-z)', 'doctor_asc'],
      ['Paciente (a-z)', 'paciente_asc'],
      ['Estado (a-z)', 'estado_asc'],
      ['Insumo (a-z)', 'insumo_asc'],
      ['Fecha recibida (la nueva primero)', 'recibida_desc'],
      ['Fecha dispensada (próxima a vencer primero)', 'dispensada_asc'],
      ['Cantidad', 'cantidad_asc']
    ]
  end

  #Métodos públicos
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
    where("date_received >= :today", { today: DateTime.now.beginning_of_day })
  end
  def self.current_month
    where("date_received >= :month", { month: DateTime.now.beginning_of_month })
  end
end
