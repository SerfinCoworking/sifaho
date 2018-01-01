class Professional < ApplicationRecord
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :dni, presence: true

  has_many :prescriptions
  belongs_to :sector

  accepts_nested_attributes_for :sector,
          :reject_if => :all_blank

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [
      :sorted_by,
      :search_query,
      :search_dni,
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
    num_or_conds = 2
    where(
      terms.map { |term|
        "(LOWER(professionals.first_name) LIKE ? OR LOWER(professionals.last_name) LIKE ?)"
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
      order("professionals.created_at #{ direction }")
    when /^nombre_/
      # Ordenamiento por nombre de droga
      order("LOWER(professionals.first_name) #{ direction }")
    when /^apellido_/
      # Ordenamiento por marca de medicamento
      order("LOWER(professionals.last_name) #{ direction }")
    when /^matricula_/
      # Ordenamiento por cantidad en stock
      order("professionals.enrollment #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :search_dni, lambda { |query|
    string = query.to_s
    where('professionals.dni::text LIKE ?', "%#{string}%")
  }

  def full_name
    if self.first_name and self.last_name
      self.first_name << " " << self.last_name
    end
  end

  # Método para establecer las opciones del select input del filtro
  # Es llamado por el controlador como parte de `initialize_filterrific`.
  def self.options_for_sorted_by
    [
      ['Creación', 'created_at_asc'],
      ['Nombre (a-z)', 'nombre_asc'],
      ['Apellido (a-z)', 'apellido_asc'],
      ['Matricula', 'matricula_asc'],
    ]
  end

end
