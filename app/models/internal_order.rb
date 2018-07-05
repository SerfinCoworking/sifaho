class InternalOrder < ApplicationRecord
  enum status: { pendiente: 0, entregado: 1, anulado: 2}

  # Relaciones
  belongs_to :responsable, class_name: 'User'
  has_many :quantity_medications, :as => :quantifiable, dependent: :destroy, inverse_of: :quantifiable
  has_many :medications, :through => :quantity_medications
  has_many :quantity_supplies, :as => :quantifiable, dependent: :destroy, inverse_of: :quantifiable
  has_many :supplies, :through => :quantity_supplies

  # Validaciones
  validates_presence_of :responsable
  validates_presence_of :date_received
  validates_associated :quantity_medications
  validates_associated :medications
  validates_associated :quantity_supplies
  validates_associated :supplies

  accepts_nested_attributes_for :quantity_medications,
          :reject_if => :all_blank,
          :allow_destroy => true
  accepts_nested_attributes_for :quantity_supplies,
          :reject_if => :all_blank,
          :allow_destroy => true

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
        "((LOWER(responsables.first_name) LIKE ? OR LOWER(responsables.last_name) LIKE ?))"
      }.join(' AND '),
      *terms.map { |e| [e] * num_or_conds }.flatten
    ).joins("INNER JOIN users AS responsables ON responsables.id = entry_notes.responsable_id")
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
      order("internal_orders.status #{ direction }")
    when /^medicamento_/
      # Ordenamiento por nombre de medicamento
      order("vademecums.medication_name #{ direction }").joins(:medications, "LEFT OUTER JOIN vademecums ON (vademecums.medication_id = medications.id)")
    when /^suministro_/
      # Ordenamiento por nombre de suministro
      order("supplies.name #{ direction }").joins(:supplies)
    when /^recibido_/
      # Ordenamiento por la fecha de recepción
      order("internal_orders.date_received #{ direction }")
    when /^entregado_/
      # Ordenamiento por la fecha de dispensación
      order("internal_orders.date_delivered #{ direction }")
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
      ['Creación (desc)', 'created_at_desc'],
      ['Responsable (a-z)', 'responsable_asc'],
      ['Estado (a-z)', 'estado_asc'],
      ['Medicamento (a-z)', 'medicamento_asc'],
      ['Suministro (a-z)', 'suministro_asc'],
      ['Fecha recibido (asc)', 'recibido_desc'],
      ['Fecha entregado (asc)', 'entregado_asc'],
      ['Cantidad (asc)', 'cantidad_asc']
    ]
  end

  # Label del estado para vista.
  def status_label
    if self.entregado?
      return 'success'
    elsif self.pendiente?
      return 'default'
    elsif self.anulado?
      return 'danger'
    end
  end
end
