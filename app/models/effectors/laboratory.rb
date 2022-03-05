class Laboratory < ApplicationRecord
  include PgSearch::Model

  # Validations
  validates_presence_of :name, :cuit, :gln

  filterrific(
    default_filter_params: { sorted_by: 'razon_social_asc' },
    available_filters: [
      :sorted_by,
      :search_name,
      :search_cuit,
      :search_gln
    ]
  )

  pg_search_scope :search_name,
                  against: :name,
                  using: { tsearch: { prefix: true } }, # Buscar coincidencia desde las primeras letras.
                  ignoring: :accents # Ignorar tildes.

  pg_search_scope :search_cuit,
                  against: :cuit,
                  using: { tsearch: { prefix: true } }, # Buscar coincidencia desde las primeras letras.
                  ignoring: :accents # Ignorar tildes.

  pg_search_scope :search_gln,
                  against: :gln,
                  using: { tsearch: { prefix: true } }, # Buscar coincidencia desde las primeras letras.
                  gnoring: :accents # Ignorar tildes.

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = sort_option =~ /desc$/ ? 'desc' : 'asc'
    case sort_option.to_s
    when /^razon_social_/
      # Ordenamiento por nombre del profesional
      order("LOWER(laboratories.name) #{direction}")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }
end
