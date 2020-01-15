class Lot < ApplicationRecord
  acts_as_paranoid
  include PgSearch

  # Relations
  belongs_to :product
  belongs_to :laboratory

  # Validations
  validates_presence_of :product, :laboratory, :code

  # Delegations
  delegate :name, :code, to: :product, prefix: true
  delegate :name, to: :laboratory, prefix: true

   filterrific(
    default_filter_params: { sorted_by: 'creado_asc' },
    available_filters: [
      :sorted_by,
      :search_lot_code,
      :search_product_code,
      :search_product,
      :search_laboratory,
    ]
  )

  # Scopes
  pg_search_scope :search_lot_code,
    against: :code,
    :using => {
      :tsearch => {:prefix => true} # Buscar coincidencia desde las primeras letras.
    },
    :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_product_code,
    :associated_against => {
      :product => :code
    },
    :using => {
      :tsearch => {:prefix => true} # Buscar coincidencia desde las primeras letras.
    },
    :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_product,
    :associated_against => {
      :product => :name
    },
    :using => {
      :tsearch => {:prefix => true} # Buscar coincidencia desde las primeras letras.
    },
    :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_laboratory,
    :associated_against => {
      :laboratory => :name
    },
    :using => {
      :tsearch => {:prefix => true} # Buscar coincidencia desde las primeras letras.
    },
    :ignoring => :accents # Ignorar tildes.

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^codigo_lote_/
      # Order by lot code
      order("lots.code::integer #{ direction }")
    when /^codigo_producto_/
      # Order by product code
      order("products.code::integer #{ direction }")
    when /^producto_/
      # Order by product name
      order("LOWER(products.name) #{ direction }")
    when /^laboratorio_/
      # Order by laboratory name
      order("LOWER(laboratories.name) #{ direction }").joins(:laboratory)
    when /^creado_/s
      # Order by lot created date
      order("lots.created_at #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }
end
