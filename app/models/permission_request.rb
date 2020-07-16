class PermissionRequest < ApplicationRecord
  include PgSearch
  
  enum status: { nueva: 0, terminada: 1, rechazada: 2 }

  belongs_to :user

  validates_presence_of :user, :establishment, :sector, :role

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [
      :search_name,
      :sorted_by
    ]
  )

  pg_search_scope :search_name,
    :associated_against => { :user => :first_name },
    :using => {:tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
    :ignoring => :accents # Ignorar tildes.

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/s
      # Ordenamiento por fecha de creación en la BD
      order("permission_requests.created_at #{ direction }")
    when /^nombre_/
      # Ordenamiento por nombre de insumo
      order("LOWER(users.name) #{ direction }").joins(:user)
    when /^unidad_/
      # Ordenamiento por la unidad
      order("LOWER(unities.name) #{ direction }").joins(:unity)
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  def self.options_for_sorted_by
    [
      ['Creación (desc)', 'created_at_desc'],
    ]
  end

end
