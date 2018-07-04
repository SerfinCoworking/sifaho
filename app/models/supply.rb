class Supply < ApplicationRecord
  after_create :assign_initial_quantity

  # Relaciones
  has_many :quantity_supplies
  has_many :prescriptions,
    :through => :quantity_supplies,
    :source => :quantifiable,
    :source_type => 'Prescription'
  has_many :internal_orders,
    :through => :quantity_supplies,
    :source => :quantifiable,
    :source_type => 'InternalOrder'

  # Validaciones
  validates_presence_of :name
  validates_presence_of :quantity
  validates_presence_of :date_received

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
    num_or_conds = 1
    where(
      terms.map { |term|
        "(LOWER(supplies.name) LIKE ?)"
      }.join(' AND '),
      *terms.map { |e| [e] * num_or_conds }.flatten
    )
  }

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/s
      # Ordenamiento por fecha de creación en la BD
      order("supplies.created_at #{ direction }")
    when /^nombre_/
      # Ordenamiento por nombre de suministro
      order("LOWER(supplies.name) #{ direction }")
    when /^fecha_recepcion_/
      # Ordenamiento por la fecha de recepción
      order("supplies.date_received #{ direction }")
    when /^fecha_expiracion_/
      # Ordenamiento por la fecha de expiración
      order("supplies.expiry_date #{ direction }")
    when /^cantidad_/
      # Ordenamiento por la cantidad
      order("supplies.quantity #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :date_received_at, lambda { |reference_time|
    where('supplies.date_received >= ?', reference_time)
  }

   # Método para establecer las opciones del select input del filtro
   # Es llamado por el controlador como parte de `initialize_filterrific`.
   def self.options_for_sorted_by
     [
       ['Creación', 'created_at_asc'],
       ['Nombre (a-z)', 'nombre_asc'],
       ['Fecha recepción (la nueva primero)', 'fecha_recepcion_desc'],
       ['Fecha expiración (prox a vencer primero)', 'fecha_expiracion_asc'],
       ['Cantidad', 'cantidad_asc']
     ]
   end

   #Métodos públicos
   def decrement(a_quantity)
     self.quantity -= a_quantity
   end

   def percent_stock
     self.quantity.to_f / self.initial_quantity  * 100 unless self.initial_quantity == 0
   end

   def quantity_label
     if self.percent_stock == 0
       return 'danger'
     elsif self.percent_stock <= 30
       return 'warning'
     else
       return 'success'
     end
   end

   private
   def assign_initial_quantity
     self.initial_quantity = self.quantity
     save!
   end
end
