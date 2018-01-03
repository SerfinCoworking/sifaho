class Patient < ApplicationRecord
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :dni, presence: true

  belongs_to :patient_type
  has_many :prescriptions

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [
      :sorted_by,
      :search_query,
      :search_dni,
      :with_patient_type_id,
    ]
  )

  # Se definen ActiveRecord scopes para
  # :search_query, :sorted_by, :search_dni, :with_patient_type_id
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
        "(LOWER(patients.first_name) LIKE ? OR LOWER(patients.last_name) LIKE ?)"
      }.join(' AND '),
      *terms.map { |e| [e] * num_or_conds }.flatten
    )
  }

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/s
      # Ordenamiento por fecha de creación en la BD
      order("patients.created_at #{ direction }")
    when /^nombre_/
      # Ordenamiento por nombre de paciente
      order("LOWER(patients.first_name) #{ direction }")
    when /^apellido_/
      # Ordenamiento por apellido de paciente
      order("LOWER(patients.last_name) #{ direction }")
    when /^tipo_de_paciente_/
      # Ordenamiento por nombre de tipo de paciente
      order("patient_types.name #{ direction }").joins(:patient_type)
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :search_dni, lambda { |query|
    string = query.to_s
    where('patients.dni::text LIKE ?', "#{string}%")
  }

  # filters on 'sector_id' foreign key
  scope :with_patient_type_id, lambda { |type_ids|
    where(patient_type_id: [*type_ids])
  }

  def full_info
    self.first_name<<" "<<self.last_name<<" "<<self.dni.to_s
  end

  # Método para establecer las opciones del select input del filtro
  # Es llamado por el controlador como parte de `initialize_filterrific`.
  def self.options_for_sorted_by
    [
      ['Creación', 'created_at_asc'],
      ['Nombre (a-z)', 'nombre_asc'],
      ['Apellido (a-z)', 'apellido_asc'],
      ['Tipo de paciente', 'tipo_de_paciente_asc'],
    ]
  end
end
