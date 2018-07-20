class Supply < ApplicationRecord
  # Relaciones
  belongs_to :supply_area

  # Validaciones
  validates_presence_of :name
  validates_presence_of :unity
  validates_presence_of :quantity_alarm
  validates_presence_of :period_control


  filterrific(
    default_filter_params: { sorted_by: 'codigo_asc' },
    available_filters: [
      :with_code,
      :sorted_by,
      :search_query,
      :with_area_id,
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
    when /^codigo_/
      # Ordenamiento por id de insumo
      order("supplies.id #{ direction }")
    when /^nombre_/
      # Ordenamiento por nombre de insumo
      order("LOWER(supplies.name) #{ direction }")
    when /^unidad_/
      # Ordenamiento por la unidad
      order("LOWER(supplies.unity) #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :with_code, lambda { |query|
    string = query.to_s
    where('supplies.id::text LIKE ?', "#{string}%")
  }

  scope :with_area_id, lambda { |an_id|
    where('supplies.supply_area_id >= ?', an_id)
  }


   # Método para establecer las opciones del select input del filtro
   # Es llamado por el controlador como parte de `initialize_filterrific`.
   def self.options_for_sorted_by
     [
       ['Código (asc)', 'codigo_asc'],
       ['Nombre (a-z)', 'nombre_asc'],
       ['Unidad (a-z)', 'unidad_asc']
     ]
   end
end
