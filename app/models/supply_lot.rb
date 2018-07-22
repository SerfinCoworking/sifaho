class SupplyLot < ApplicationRecord
  enum status: { vigente: 0, por_vencer: 1, vencido: 2}

  after_create :update_status, :assign_constants
  before_update :update_status, if: :will_save_change_to_expiry_date?

  # Relaciones
  belongs_to :supply
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
  validates_presence_of :supply
  validates_presence_of :quantity
  validates_presence_of :date_received


  filterrific(
    default_filter_params: { sorted_by: 'creacion_desc' },
    available_filters: [
      :with_code,
      :sorted_by,
      :search_query,
      :with_area_id,
      :date_received_at
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
        "(LOWER(supply_lots.name) LIKE ?)"
      }.join(' AND '),
      *terms.map { |e| [e] * num_or_conds }.flatten
    )
  }

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^creacion_/
      # Ordenamiento por fecha de recepción
      order("supply_lots.created_at #{ direction }")
    when /^codigo_/
      # Ordenamiento por código de lote
      order("LOWER(supply_lots.code) #{ direction }")
    when /^insumo_/
      # Ordenamiento por nombre del insumo
      order("LOWER(supply_lots.supply_name) #{ direction }")
    when /^estado_/
      # Ordenamiento por estado del lote
      order("supply_lots.status #{ direction }")
    when /^cantidad_inicial_/
      # Ordenamiento por cantidad inicial del lote
      order("supply_lots.initial_quantity #{ direction }")
    when /^cantidad_/
      # Ordenamiento por cantidad actual del lote
      order("supply_lots.quantity #{ direction }")
    when /^fecha_recepcion_/
      # Ordenamiento por fecha de recepción
      order("supply_lots.date_received #{ direction }")
    when /^fecha_expiracion_/
      # Ordenamiento por fecha de expiración
      order("supply_lots.expiry_date #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :with_code, lambda { |query|
    string = query.to_s
    where('supply_lots.id::text LIKE ?', "#{string}%")
  }

  scope :date_received_at, lambda { |reference_time|
    where('supply_lots.date_received >= ?', reference_time)
  }

   # Método para establecer las opciones del select input del filtro
   # Es llamado por el controlador como parte de `initialize_filterrific`.
   def self.options_for_sorted_by
     [
       ['Creación (desc)', 'creacion_desc'],
       ['Código (asc)', 'codigo_asc'],
       ['Insumo (a-z)', 'insumo_asc'],
       ['Cantidad (asc)', 'cantidad_asc'],
       ['Cantidad inicial (asc)', 'cantidad_inicial_asc'],
       ['Fecha recepción (asc)', 'fecha_recepcion_asc'],
       ['Fecha expiración (asc)', 'fecha_expiracion_asc'],
     ]
   end

  #Métodos públicos
  # Disminuye la cantidad
  def decrement(a_quantity)
    self.quantity -= a_quantity
  end

  # Retorna el porcentaje actual de stock
  def percent_stock
    self.quantity.to_f / self.initial_quantity  * 100 unless self.initial_quantity == 0
  end

  # Label de porcentaje de stock para vista.
  def quantity_label
    if self.percent_stock == 0
      return 'danger'
    elsif self.percent_stock <= 30
      return 'warning'
    else
      return 'success'
    end
  end

  # Label del estado para vista.
  def status_label
    if self.vigente?
      return 'success'
    elsif self.por_vencer?
      return 'warning'
    elsif self.vencido?
      return 'danger'
    end
  end

  # Métodos de clase
  def self.expired # Retorna los medicamentos expirados
    where(status: [:vencido])
  end
  def self.near_expiry # Retorna los medicamentos pronto a expirar
    where(status: [:por_vencer])
  end
  def self.in_good_state # Retorna los medicamentos en buen estado
    where(status: [:vigente])
  end

  private
  # Se actualiza el estado de expiración
  def update_status
    if expiry_date?
      # If expired
      if self.expiry_date <= DateTime.now
        self.status = "vencido"
        # If near_expiry
      elsif expiry_date < DateTime.now + 3.month && expiry_date > DateTime.now
        self.status = "por_vencer"
        # If good
      elsif expiry_date > DateTime.now
        self.status = "vigente"
      end
    end
  end

  # Se asigna la cantidad inicial
  def assign_constants
    self.initial_quantity = self.quantity
    self.code = self.supply_id.to_s
    self.supply_name = self.supply.name
    save!
  end
end
