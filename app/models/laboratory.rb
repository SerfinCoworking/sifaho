class Laboratory < ApplicationRecord
  include PgSearch

  # Relaciones
  has_many :supply_lots

  # Validaciones
  validates_presence_of :name
  validates_presence_of :cuit
  validates_presence_of :gln

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [
      :sorted_by,
      :search_name,
      :search_cuit,
      :search_gln,
    ]
  )

  pg_search_scope :search_name,
  against: :name,
  :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_cuit,
  against: :cuit,
  :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_gln,
  against: :gln,
  :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/s
      # Ordenamiento por fecha de creación en la BD
      order("laboratories.created_at #{ direction }")
    when /^razon_social_/
      # Ordenamiento por nombre del profesional
      order("LOWER(laboratories.name) #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  # Método para establecer las opciones del select input del filtro
  # Es llamado por el controlador como parte de `initialize_filterrific`.
  def self.options_for_sorted_by
    [
      ['Creación', 'created_at_asc'],
      ['Razón social (a-z)', 'razon_social_asc'],
    ]
  end

end
