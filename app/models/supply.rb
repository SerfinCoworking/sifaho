class Supply < ApplicationRecord
  validates_presence_of :name, presence: true
  validates_presence_of :quantity, presence: true
  validates_presence_of :date_received, presence: true

  has_many :quantity_supplies
  has_many :prescriptions,
           :through => :quantity_supplies,
           :source => :quantifiable,
           :source_type => 'Prescription'

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
    num_or_conds = 1
    where(
      terms.map { |term|
        "(LOWER(supplies.name) LIKE ?)"
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
      order("supplies.created_at #{ direction }")
    when /^nombre_/
      # Ordenamiento por nombre de suministro
      order("LOWER(supplies.name) #{ direction }")
    when /^recibida_/
      # Ordenamiento por la fecha de recepción
      order("supplies.date_received #{ direction }")
    when /^cantidad_/
      # Ordenamiento por la cantidad
      order("supplies.quantity #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :date_received_at, lambda { |reference_time|
    where('supplies.date_received >= ?', reference_time)
  }

   # Método para establecer las opciones del select input del filtro
   # Es llamado por el controlador como parte de `initialize_filterrific`.
   def self.options_for_sorted_by
     [
       ['Creación', 'created_at_asc'],
       ['Nombre (a-z)', 'nombre_asc'],
       ['Fecha recibida (la nueva primero)', 'recibida_desc'],
       ['Cantidad', 'cantidad_asc']
     ]
   end
end
