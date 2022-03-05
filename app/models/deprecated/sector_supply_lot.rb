class SectorSupplyLot < ApplicationRecord
  acts_as_paranoid
  include PgSearch::Model

  enum status: { vigente: 0, por_vencer: 1, vencido: 2, agotado: 3, archivado: 4 }

  # Callbacks
  before_validation :assign_constants
  # before_validation :assign_stock, if: :need_stock? 
  after_validation :update_status
  # after_validation :update_status, :update_stock

  # Relaciones
  belongs_to :sector
  belongs_to :stock, optional: true
  belongs_to :supply_lot, -> { with_deleted }
  has_one :supply, :through => :supply_lot
  has_one :supply_area, through: :supply

  has_many :quantity_ord_supply_lots
  has_many :prescriptions, -> { with_deleted },
    :through => :quantity_ord_supply_lots,
    :source => :quantifiable,
    :source_type => 'Prescription'

  has_many :internal_orders, -> { with_deleted },
    :through => :quantity_ord_supply_lots,
    :source => :quantifiable,
    :source_type => 'InternalOrder'

  has_many :external_orders, -> { with_deleted },
    :through => :quantity_ord_supply_lots,
    :source => :quantifiable,
    :source_type => 'ExternalOrder'

  # Validaciones
  validates_presence_of :supply_lot, :quantity, :initial_quantity

  # Delegaciones
  delegate :unity, :format_expiry_date, :code, :lot_code, :supply_name, :expiry_date, :needs_expiration?, to: :supply_lot

  filterrific(
    default_filter_params: { sorted_by: 'codigo_asc' },
    available_filters: [
      :with_code,
      :sorted_by,
      :with_status,
      :search_supply_by_name_or_code,
      :date_received_at
    ]
  )

  # SCOPES #--------------------------------------------------------------------
  
  pg_search_scope :with_code,
  :associated_against => {
    :supply_lot => :code
  },
  :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_supply_by_name_or_code,
  associated_against: { :supply_lot => :supply_name },
  :using => {
    :tsearch => {:prefix => true} # Buscar coincidencia desde las primeras letras.
  },
  :ignoring => :accents # Ignorar tildes.

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^recepcion_/
      # Ordenamiento por fecha de recepción
      order("sector_supply_lots.created_at #{ direction }")
    when /^lote_/
      # Ordenamiento por código de lote
      order("LOWER(supply_lots.lot_code) #{ direction }").joins(:supply_lot)
    when /^cod_ins_/
      # Ordenamiento por código de lote
      order("LOWER(supply_lots.code) #{ direction }").joins(:supply_lot)
    when /^insumo_/
      # Ordenamiento por nombre del insumo
      order("LOWER(supply_lots.supply_name) #{ direction }").joins(:supply_lot)
    when /^estado_/
      # Ordenamiento por estado del lote
      order("sector_supply_lots.status #{ direction }")
    when /^cantidad_inicial_/
      # Ordenamiento por cantidad inicial del lote
      order("sector_supply_lots.initial_quantity #{ direction }")
    when /^cantidad_/
      # Ordenamiento por cantidad actual del lote
      order("sector_supply_lots.quantity #{ direction }")
    when /^vencimiento_/
      # Ordenamiento por fecha de expiración
      order("supply_lots.expiry_date #{ direction }").joins(:supply_lot)
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :date_received_at, lambda { |reference_time|
    where('sector_supply_lots.created_at >= ?', reference_time)
  }

  scope :with_status, lambda { |a_status|
    where('sector_supply_lots.status = ?', a_status)
  }

  scope :without_status, lambda { |a_status|
    where.not('sector_supply_lots.status = ?', a_status )
  }

  scope :with_supply, lambda { |a_supply| 
    where('supply_lots.supply_id = ?', a_supply.id).joins(:supply_lot)
  }

  # Métodos públicos #----------------------------------------------------------
  def laboratory
    self.supply_lot.laboratory_name
  end

  # Método para incrementar la cantidad del lote. 
  # Si se encuentra archivado, vuelve a vigente con 0 de cantidad.
  def increment(a_quantity)
    if self.archivado?
      self.quantity = 0
      self.vigente!; 
    end
    self.quantity += a_quantity
    self.save!
  end

  # Disminuye la cantidad
  def decrement(a_quantity)
    if self.quantity < a_quantity
      raise ArgumentError, "Cantidad en stock insuficiente del lote "+self.lot_code+" insumo "+self.supply_name
    elsif self.deleted?
      raise ArgumentError, "El lote "+self.lot_code+" de "+self.supply_name+" se encuentra en la papelera"
    else
      self.quantity -= a_quantity
      self.save!
    end
  end

  # Retorna el porcentaje actual de stock
  def percent_stock
    self.quantity.to_f / self.initial_quantity  * 100
  end

  # Label de porcentaje de stock para vista.
  def quantity_label
    if self.percent_stock == 0 || self.percent_stock.nil?
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
    elsif self.agotado?
      return 'info'
    elsif self.archivado?
      return 'default'
    end
  end

  # Se actualiza el estado del lote
  def update_status_without_validate!
    unless self.archivado?
      if self.quantity == 0
        self.status = 'agotado'
      elsif self.supply_lot.present? && self.supply_lot.expiry_date.present?
        self.status = self.supply_lot.status
      end
    end
    self.save(validate: false)
  end

  # Métodos privados #----------------------------------------------------------

  private
  # Se actualiza el estado del lote
  def update_status
    unless self.archivado?
      if self.quantity == 0
        self.status = 'agotado'
      elsif self.supply_lot.expiry_date.present?
        @exp_date = self.supply_lot.expiry_date
        # If expired
        if @exp_date <= DateTime.now
          self.status = 'vencido'
        # If near_expiry
        elsif @exp_date < DateTime.now + 3.month && @exp_date > DateTime.now
          self.status = 'por_vencer'
        # If good
        elsif @exp_date > DateTime.now
          self.status = 'vigente'
        end 
      else
        self.status = 'vigente'
      end
    end
  end

  # Se asigna la cantidad inicial
  def assign_constants
    if self.initial_quantity < self.quantity # Si se edita y coloca una cantidad mayor a la inicial
      self.initial_quantity = self.quantity # Se vuelve a asignar la cantidad inicial
    end
  end

  # Se asigna el stock correspondiente
  def assign_stock
    self.stock = Stock.first_or_create(sector: self.sector, product: Product.find_by_code(self.code))
  end

  # Se actualiza la cantidad en stock
  def update_stock
    self.stock.update_stock 
  end

  # Retorna verdadero si tiene sector pero aún no tiene stock asignado
  def need_stock?
    return self.sector.present? && self.stock.blank?
  end


  # Métodos de clase #----------------------------------------------------------

  def self.lots_for_sector(a_sector)
    where(sector: a_sector)
  end

  # Método para establecer las opciones del select input del filtro
  # Es llamado por el controlador como parte de `initialize_filterrific`.
  def self.options_for_sorted_by
   [
     ['Fecha recepción (desc)', 'recepcion_desc'],
     ['Fecha vencimiento (asc)', 'vencimiento_asc'],
     ['Código de lote (asc)', 'lote_asc'],
     ['Código de insumo (asc)', 'cod_ins_asc'],
     ['Insumo (a-z)', 'insumo_asc'],
     ['Estado', 'estado_asc'],
     ['Cantidad (asc)', 'cantidad_asc'],
     ['Cantidad inicial (asc)', 'cantidad_inicial_asc'],
   ]
  end

  def self.options_for_status
   [
     ['Todos', '', 'default'],
     ['Vigentes', 0, 'success'],
     ['Por vencer', 1, 'warning'],
     ['Vencidos', 2, 'danger'],
     ['Agotados', 3, 'info'],
   ]
  end

  def self.update_status_to_all
    self.find_each do |lot|
      lot.update_status_without_validate!
    end
  end
end
