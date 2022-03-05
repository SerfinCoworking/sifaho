class Bedroom < ApplicationRecord
  include PgSearch::Model

  # Relationships
  belongs_to :location_sector, class_name: 'Sector'
  has_one :establishment, :through => :location_sector
  has_many :beds

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :location_sector, presence: true

  filterrific(
    default_filter_params: { sorted_by: 'nombre_desc' },
    available_filters: [
      :search_name,
      :sorted_by
    ]
  )

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = sort_option =~ /desc$/ ? 'desc' : 'asc'
    case sort_option.to_s
    when /^nombre_/
      # Sort by name
      reorder("bedrooms.name #{direction}")
    when /^ubicacion_/
      # Order by location
      reorder("location_sectors.name #{direction}").joins(:location_sector)
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  def self.options_for_sorted_by
    [
      ['Nombre (a-z)', 'nombre_desc'],
      ['Nombre (z-a)', 'nombre_asc'],
      ['Ubicación (a-z)', 'ubicacion_desc'],
      ['Ubicación (z-a)', 'ubicacion_asc']
    ]
  end

  pg_search_scope :search_name,
                  against: :name,
                  using: { tsearch: { prefix: true } }, # Buscar coincidencia desde las primeras letras.
                  ignoring: :accents # Ignorar tildes.

  scope :establishment, ->(establishment_id) { joins(:establishment).where("establishments.id=?", establishment_id) }
end
