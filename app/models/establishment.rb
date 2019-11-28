class Establishment < ApplicationRecord
  include PgSearch

  # Relaciones
  has_many :sectors
  has_many :users, :through => :sectors
  has_many :prescriptions

  # SCOPES #--------------------------------------------------------------------
  pg_search_scope :search_name,
  against: :name,
  :using => {
    :tsearch => {:prefix => true} # Buscar coincidencia desde las primeras letras.
  },
  :ignoring => :accents # Ignorar tildes.

  filterrific(
    default_filter_params: { sorted_by: 'codigo_asc' },
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
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

    # Método para establecer las opciones del select input del filtro
  # Es llamado por el controlador como parte de `initialize_filterrific`.
  def self.options_for_system_status
    [
      ['Creación (desc)', 'created_at_desc'],
      ['Nombre (a-z)', 'sector_asc'],
      ['Responsable (a-z)', 'responsable_asc'],
      ['Estado (a-z)', 'estado_asc'],
      ['Insumos solicitados (a-z)', 'insumos_solicitados_asc'],
      ['Fecha recibido (asc)', 'recibido_desc'],
      ['Fecha entregado (asc)', 'entregado_asc'],
      ['Cantidad (asc)', 'cantidad_asc']
    ]
  end

  def self.options_for_status
    [
      ['Todos', '', 'default'],
      ['Solicitud auditoria', 0, 'warning'],
      ['Solicitud enviada', 1, 'info'],
      ['Proveedor auditoria', 2, 'warning'],
      ['Provision en camino', 3, 'primary'],
      ['Provision entregada', 4, 'success'],
      ['Anulada', 5, 'danger'],
    ]
  end
end
