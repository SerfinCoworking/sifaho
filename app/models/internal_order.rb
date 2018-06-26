class InternalOrder < ApplicationRecord
  enum status: { pendiente: 0, dispensado: 1, anulado: 2}

  # Relaciones
  belongs_to :responsable, class_name: 'User'

  # Validaciones
  validates_presence_of :responsable
  validates_associated :quantity_medications
  validates_associated :medications
  validates_associated :quantity_supplies
  validates_associated :supplies

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [
      :sorted_by,
      :search_query,
      :date_received_at,
    ]
  )

  # define ActiveRecord scopes for
  # :search_query, :sorted_by, :date_received_at
  scope :search_query, lambda { |query|
    #Se retorna nil si no hay texto en la query
    return nil  if query.blank?

    # Se pasa a minusculas para busqueda en postgresql
    # Luego se dividen las palabras en claves individuales
    terms = query.downcase.split(/\s+/)

    # Remplaza "*" con "%" para busquedas abiertas con LIKE
    # Agrega '%', remueve los '%' duplicados
    terms = terms.map { |e|
      (e.gsub('*', '%') + '%').gsub(/%+/, '%')
    }

    # Cantidad de condiciones.
    num_or_conds = 2
    where(
      terms.map { |term|
        "((LOWER(user.first_name) LIKE ? OR LOWER(user.last_name) LIKE ?))"
      }.join(' AND '),
      *terms.map { |e| [e] * num_or_conds }.flatten
    ).joins(:user)
  }

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/s
      # Ordenamiento por fecha de creación en la BD
      order("internal_orders.created_at #{ direction }")
    when /^responsable_/
      # Ordenamiento por nombre de responsable
      order("LOWER(users.full_name) #{ direction }").joins(:user)
    when /^estado_/
      # Ordenamiento por nombre de estado
      order("prescription_statuses.name #{ direction }").joins(:prescription_status)
    when /^medicamento_/
      # Ordenamiento por nombre de medicamento
      order("vademecums.medication_name #{ direction }").joins(:medications, "LEFT OUTER JOIN vademecums ON (vademecums.medication_id = medications.id)")
    when /^suministro_/
      # Ordenamiento por nombre de suministro
      order("supplies.name #{ direction }").joins(:supplies)
    when /^recibido_/
      # Ordenamiento por la fecha de recepción
      order("internal_orders.date_received #{ direction }")
    when /^dispensado_/
      # Ordenamiento por la fecha de dispensación
      order("internal_orders.date_dispensed #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :date_received_at, lambda { |reference_time|
    where('internal_orders.date_received >= ?', reference_time)
  }

  # Método para establecer las opciones del select input del filtro
  # Es llamado por el controlador como parte de `initialize_filterrific`.
  def self.options_for_sorted_by
    [
      ['Creación', 'created_at_asc'],
      ['Responsable (a-z)', 'responsable_asc'],
      ['Estado (a-z)', 'estado_asc'],
      ['Medicamento (a-z)', 'medicamento_asc'],
      ['Suministro (a-z)', 'suministro_asc'],
      ['Fecha recibido (el mas nuevo primero)', 'recibido_desc'],
      ['Fecha dispensado (el primero dispensado)', 'despensado_asc'],
      ['Cantidad', 'cantidad_asc']
    ]
  end
end
