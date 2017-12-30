class Prescription < ApplicationRecord

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [
      :sorted_by,
      :search_query,
      :date_received_at,
    ]
  )

  belongs_to :professional
  belongs_to :patient
  belongs_to :prescription_status

  has_many :quantity_medications, :as => :quantifiable, dependent: :destroy, inverse_of: :quantifiable
  has_many :medications, :through => :quantity_medications
  has_many :quantity_supplies, :as => :quantifiable, dependent: :destroy, inverse_of: :quantifiable
  has_many :supplies, :through => :quantity_supplies


  accepts_nested_attributes_for :quantity_medications,
          :reject_if => :all_blank,
          :allow_destroy => true
  accepts_nested_attributes_for :quantity_supplies,
          :reject_if => :all_blank,
          :allow_destroy => true
  accepts_nested_attributes_for :medications
  accepts_nested_attributes_for :patient,
          :reject_if => :all_blank
  accepts_nested_attributes_for :professional,
          :reject_if => :all_blank

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
    num_or_conds = 2
    where(
      terms.map { |term|
        "(LOWER(professionals.first_name) LIKE ? OR LOWER(patients.first_name) LIKE ? OR (LOWER(professionals.last_name) LIKE ? OR LOWER(patients.last_name))"
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
      # Ordenamiento por cantidad en stock
      order("prescription_statuses.name #{ direction }").joins(:prescription_status)
    when /^medicacion_/
      # Ordenamiento por cantidad en stock
      order("vademecums.medication_name #{ direction }").joins(:medication, :vademecum)
    when /^suministro_/
      # Ordenamiento por cantidad en stock
      order("supplies.name #{ direction }").joins(:supply)
    when /^fecha_recepcion_/
      # Ordenamiento por la fecha de recepción
      order("prescriptions.date_received #{ direction }")
    when /^fecha_dispensada_/
      # Ordenamiento por la fecha de expiración
      order("prescriptions.date_dispensed #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :date_received_at, lambda { |reference_time|
    where('prescriptions.date_received >= ?', reference_time)
  }

  def dispensed?
    self.prescription_status.is_dispense?
  end

  # Método para establecer las opciones del select input del filtro
  # Es llamado por el controlador como parte de `initialize_filterrific`.
  def self.options_for_sorted_by
    [
      ['Creación', 'created_at_asc'],
      ['Doctor (a-z)', 'doctor_asc'],
      ['Paciente (a-z)', 'paciente_asc'],
      ['Estado (a-z)', 'estado_asc'],
      ['Medicación (a-z)', 'medicacion_asc'],
      ['Suministro (a-z)', 'suministro_asc'],
      ['Fecha recepción (la nueva primero)', 'fecha_recepcion_desc'],
      ['Fecha dispensada (próxima a vencer primero)', 'fecha_dispensada_asc'],
      ['Cantidad', 'cantidad_asc']
    ]
  end
end
