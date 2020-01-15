class Product < ApplicationRecord  
  acts_as_paranoid
  include PgSearch
  
  # Relations
  belongs_to :unity, optional: true
  belongs_to :area
  
  # Validations
  validates_presence_of :name, :code, :area
  validates_uniqueness_of :code

  # Delegations
  delegate :name, to: :area, prefix: true
  delegate :name, to: :unity, prefix: true

  filterrific(
    default_filter_params: { sorted_by: 'codigo_asc' },
    available_filters: [
      :search_code,
      :sorted_by,
      :search_supply,
      :with_area_id,
    ]
  )

  # Scopes
  pg_search_scope :search_code,
    against: :code,
    :using => {
      :tsearch => {:prefix => true} # Buscar coincidencia desde las primeras letras.
    },
    :ignoring => :accents # Ignorar tildes.

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
      order("products.code::integer #{ direction }")
    when /^nombre_/
      # Ordenamiento por nombre de insumo
      order("LOWER(products.name) #{ direction }")
    when /^unidad_/
      # Ordenamiento por la unidad
      order("LOWER(unities.name) #{ direction }").joins(:unity)
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :with_area_id, lambda { |an_id|
    where('products.supply_area_id = ?', an_id)
  }

  def self.search_supply(a_name)
    Supply.search_text(a_name).with_pg_search_rank
  end

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
