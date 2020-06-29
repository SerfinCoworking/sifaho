class Establishment < ApplicationRecord
  include PgSearch

  # Relaciones
  has_many :sectors
  has_many :users, :through => :sectors
  has_many :prescriptions

  # Validations
  validates_presence_of :name, :code
  
  # SCOPES #--------------------------------------------------------------------
  pg_search_scope :search_name,
  against: :name,
  :using => {
    :tsearch => {:prefix => true} # Buscar coincidencia desde las primeras letras.
  },
  :ignoring => :accents # Ignorar tildes.

  filterrific(
    default_filter_params: { sorted_by: 'name_asc' },
    available_filters: [
      :sorted_by,
      :search_name,
    ]
  )

  scope :where_not_id, lambda { |an_id|
    where.not(id: [*an_id])
  }

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/s
      # Ordenamiento por fecha de creación en la BD
      order("establishments.created_at #{ direction }")
    when /^name_/s
      # Ordenamiento por fecha de creación en la BD
      order("establishments.name #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  def short_name
    super.presence || self.name
  end
end
