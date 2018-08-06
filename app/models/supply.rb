class Supply < ApplicationRecord
  include PgSearch
  # Relaciones
  belongs_to :supply_area

  # Validaciones
  validates_presence_of :name
  validates_presence_of :unity
  validates_presence_of :quantity_alarm
  validates_presence_of :period_control

  has_many :quantity_supply_lots
  has_many :prescriptions,
    :through => :quantity_supply_lots,
    :source => :quantifiable,
    :source_type => 'Prescription'

  has_many :internal_orders,
    :through => :quantity_supply_lots,
    :source => :quantifiable,
    :source_type => 'InternalOrder'


  filterrific(
    default_filter_params: { sorted_by: 'codigo_asc' },
    available_filters: [
      :with_code,
      :sorted_by,
      :search_text,
      :with_area_id,
    ]
  )

  pg_search_scope :search_text,
  against: :name,
  :associated_against => {
    :supply_area => :name
  },
  :using => {
    :tsearch => {:prefix => true} # Buscar coincidencia desde las primeras letras.
  },
  :ignoring => :accents # Ignorar tildes.

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
    where('supplies.supply_area_id = ?', an_id)
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
