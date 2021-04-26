class Bed < ApplicationRecord
  include PgSearch
  enum status: { disponible: 0, ocupada: 1, inactiva: 2 } 

  belongs_to :bedroom
  belongs_to :service, class_name: 'Sector'
  has_one :establishment, through: :bedroom
  has_many :bed_orders
  has_one :patient

  validates :name, presence: true, uniqueness: true
  validates :bedroom, presence: true

  scope :establishment, -> (establishment_id) {joins(:establishment).where("establishments.id=?", establishment_id)}

  filterrific(
    default_filter_params: { sorted_by: 'estado_desc' },
    available_filters: [
      :search_name,
      :search_sector,
      :sorted_by,
      :with_status
    ]
  )

  pg_search_scope :search_name,
    against: :name,
    :using => {:tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
    :ignoring => :accents # Ignorar tildes.

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^cama_/
      # Ordenamiento por nombre de sector
      reorder("beds.name #{ direction }")
    when /^sector_/
      # Ordenamiento por nombre de estado
      reorder("sectors.name #{ direction }").joins(:sector)
    when /^estado_/
      # Ordenamiento por nombre de estado
      reorder("beds.status #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  def self.options_for_sorted_by
    [
      ['Cama (a-z)', 'cama_desc'],
      ['Cama (z-a)', 'cama_asc'],
      ['Sector (a-z)', 'sector_desc'],
      ['Sector (z-a)', 'sector_asc'],
      ['Estado (a-z)', 'estado_desc'],
      ['Estado (z-a)', 'estado_asc'],
    ]
  end

  def self.options_for_status
    [
      ['Todas', '', 'default'],
      ['Disponible', 0, 'success'],
      ['Ocupada', 1, 'warning'],
      ['Inactiva', 2, 'secondary'],
    ]
  end

  scope :with_status, ->(a_status) { where('beds.status = ?', a_status) }

end
