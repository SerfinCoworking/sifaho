class LotStock < ApplicationRecord
  # Relationships
  belongs_to :lot
  belongs_to :stock
  has_many :int_ord_prod_lot_stocks
  has_many :ext_ord_prod_lot_stocks
  has_many :out_pres_prod_lot_stocks
  has_many :chron_pres_prod_lot_stocks
  has_many :in_pre_prod_lot_stocks
  has_many :receipt_products
  has_many :lot_archives
  has_many :movements, class_name: 'StockMovement'
  has_many :external_orders, through: :ext_ord_prod_lot_stocks, source: :order
  has_one :sector, through: :stock
  has_one :product, through: :lot

  # Callbacks
  after_save :stock_refresh_quantity

  # Validations
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :reserved_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates_presence_of :stock_id

  # Delegations
  delegate :refresh_quantity, to: :stock, prefix: true
  delegate :name, :code, to: :product, prefix: true
  delegate :code, :laboratory_name, :expiry_date_string, :status, :provenance_name,
           :short_expiry_date_string, to: :lot, prefix: true

  filterrific(
    default_filter_params: { sorted_by: 'expiry_desc' },
    available_filters: [
      :sorted_by,
      :search_by_status,
      :search_by_quantity
    ]
  )

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = sort_option =~ /desc$/ ? 'desc' : 'asc'
    case sort_option.to_s
    when /^expiry_/s
      # Ordenamiento por fecha de modificación en la BD
      reorder("lots.expiry_date #{direction}").joins(:lot)
    # when /^created_at_/s
    #   # Ordenamiento por fecha de creacion en la BD
    #   reorder("lot_stocks.created_at #{ direction }")
    # when /^medico_/
    #   # Ordenamiento por nombre de droga
    #   reorder("LOWER(professionals.last_name) #{ direction }").joins(:professional)
    # when /^paciente_/
    #   # Ordenamiento por marca de medicamento
    #   reorder("LOWER(patients.last_name) #{ direction }").joins(:patient)
    # when /^estado_/
    #   # Ordenamiento por nombre de estado
    #   reorder("lot_stocks.status #{ direction }")
    # when /^recetada_/
    #   # Ordenamiento por la fecha de recepcion
    #   reorder("lot_stocks.date_prescribed #{ direction }")
    # when /^creado_/
    #   # Ordenamiento por la fecha de recepcion
    #   reorder("lot_stocks.created_at #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  scope :with_product, ->(a_product) { where('lot_stocks.product_id = ?', a_product.id).joins(:lot) }

  scope :with_status, ->(status) { where('lots.status = ?', status).joins(:lot) }

  scope :without_status, ->(a_status) { where.not('lots.status = ?', a_status) }

  scope :lots_for_sector, ->(a_sector) { where(sector: a_sector) }

  scope :by_stock, ->(stock_id) { where(stock_id: stock_id) }

  scope :greater_than_zero, -> { where('lot_stocks.quantity > 0 OR lot_stocks.reserved_quantity > 0') }

  scope :search_by_status, ->(status) { joins(:lot).where('lots.status = ?', status) }

  scope :search_by_quantity, lambda { |quantity|
    if quantity == 0 || quantity == 1
      quantity == 0 ? where('lot_stocks.quantity = 0') : where('lot_stocks.quantity > 0')
    end
  }

  def self.options_for_status
    [
      ['Todos', '', 'default'],
      ['Vigente', 0, 'success'],
      ['Por vencer', 1, 'warning'],
      ['Vencido', 2, 'danger']
    ]
  end

  def self.options_for_quantity
    [
      ['Todos', '', 'default'],
      ['Igual a 0', 0, 'warning'],
      ['Mayor a 0', 1, 'success']
    ]
  end

  def self.options_for_sort
    [
      ['Fecha vencimiento (nueva primero)', 'expiry_desc', 'warning'],
      ['Fecha vencimiento (antigua primero)', 'expiry_asc', 'success']
    ]
  end

  # Metodo para incrementar la cantidad del lote.
  # Si se encuentra archivado, vuelve a vigente con 0 de cantidad.
  def increment(a_quantity)
    self.quantity += a_quantity
    self.save!
  end

  # Disminuye la cantidad del stock
  def decrement(a_quantity)
    if self.quantity < a_quantity
      raise ArgumentError, "Cantidad en stock insuficiente del lote "+self.lot_code+" producto "+self.product_name
    else
      self.quantity -= a_quantity
      self.save!
    end
  end

  # Incrementa la cantidad archivada y resta la cantidad en stock
  def increment_archived(a_quantity)
    self.decrement(a_quantity)
    self.archived_quantity += a_quantity
    self.save!
  end

  # Decrementa la cantidad archivada y la suma a la cantidad en stock
  def decrement_archived(a_quantity)
    self.increment(a_quantity)
    self.archived_quantity -= a_quantity
    self.save!
  end

  # Decrementa la cantidad reservada sin modificar otras cantidades
  def decrement_reserved(a_quantity)
    self.reserved_quantity -= a_quantity
    self.save!
  end

  # Habilita la cantidad reservada nuevamente en stock
  def enable_reserved(a_quantity)
    self.increment(a_quantity)
    self.reserved_quantity -= a_quantity
    self.save!
  end

  # Mueve cantidad del stock a reservado
  def reserve(a_quantity)
    self.decrement(a_quantity)
    self.reserved_quantity += a_quantity
    self.save!
  end

  def total_quantity
    self.quantity + self.reserved_quantity
  end
end
