class Report < ApplicationRecord
  enum report_type: { consumption_date: 0 }

  belongs_to :supply
  belongs_to :sector
  belongs_to :user

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [
      :sorted_by
    ]
  )

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/s
      # Ordenamiento por fecha de creación en la BD
      order("reports.created_at #{ direction }")
    when /^solicitado_por_/
      # Ordenamiento por nombre de usuario
      order("LOWER(responsable.username) #{ direction }").joins("INNER JOIN users as responsable ON responsable.id = reports.responsable_id")
    when /^desde_/
      # Ordenamiento por la fecha de recepción
      order("reports.since_date #{ direction }")
    when /^hasta_/
      # Ordenamiento por la fecha de recepción
      order("reports.to_date #{ direction }")
    when /^creado_/
      # Ordenamiento por la fecha de recepción
      order("reports.created_at #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }
  
  # Método para establecer las opciones del select input del filtro
  # Es llamado por el controlador como parte de `initialize_filterrific`.
  def self.options_for_sorted_by
    [
      ['Creación (desc)', 'created_at_desc'],
      ['Sector (a-z)', 'sector_asc'],
      ['Responsable (a-z)', 'responsable_asc'],
      ['Estado (a-z)', 'estado_asc'],
      ['Insumos solicitados (a-z)', 'insumos_solicitados_asc'],
      ['Fecha recibido (asc)', 'recibido_desc'],
    ]
  end

  def self.to_sector(a_sector)
    where(sector: a_sector)
  end
end
