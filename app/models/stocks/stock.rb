class Stock < ApplicationRecord
  include PgSearch::Model

  # Relationships
  belongs_to :product
  belongs_to :sector
  has_many :lot_stocks
  has_one :area, through: :product
  has_one :unity, through: :product
  has_many :movements, class_name: 'StockMovement'

  # Validations
  validates_presence_of :product, :sector

  # Delegations
  delegate :code, :name, :unity_name, :area_name, to: :product, prefix: true

  filterrific(
    default_filter_params: { sorted_by: 'nombre_asc' },
    available_filters: [
      :search_product_code,
      :search_product_name,
      :with_area_ids,
      :sorted_by
    ]
  )

  # Scopes
  pg_search_scope :search_product_code,
                  associated_against: { product: [:code] },
                  using: { tsearch: { prefix: true } }, # Buscar coincidencia desde las primeras letras.
                  ignoring: :accents # Ignorar tildes.

  pg_search_scope :search_product_name,
                  associated_against: { product: [:name] },
                  using: { tsearch: { prefix: true } }, # Buscar coincidencia desde las primeras letras.
                  ignoring: :accents # Ignorar tildes.

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = sort_option =~ /desc$/ ? 'desc' : 'asc'
    case sort_option.to_s
    when /^modificado_/s
      # Ordenamiento por fecha de creación en la BD
      reorder("stocks.updated_at #{direction}")
    when /^codigo_/
      # Ordenamiento por id de insumo
      reorder("products.code #{direction}").joins(:product)
    when /^cantidad_/
      # Ordenamiento por la cantidad de stock
      reorder("stocks.quantity #{direction}")
    when /^nombre_/
      # Ordenamiento por el nombre del producto
      reorder("products.name #{direction}").joins(:product)
    when /^rubro_/
      # Ordenamiento por el rubro del producto
      reorder("areas.name #{direction}").joins(:product, :area)
    when /^unidad_/
      # Ordenamiento por la unidad del prudcto
      reorder("unities.name #{direction}").joins(:product, :unity)
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  scope :to_sector, ->(sector) { where('stocks.sector_id = ?', sector.id) }

  scope :with_product_ids, ->(product_ids) { joins(:product).where('products.id': product_ids) }

  scope :by_product_code, ->(product_code) { joins(:product).where('products.code': product_code) }

  scope :with_area_ids, ->(area_ids) { joins(:product).where('products.area_id': area_ids) }

  scope :with_available_quantity, -> { joins(:lot_stocks).where('lot_stocks.quantity > ?', 0) }

  scope :with_lot_stocks, ->(id) { find(id).lot_stocks }

  def self.options_for_sorted_by
    [
      ['Código (asc)', 'codigo_asc'],
      ['Nombre (a-z)', 'nombre_asc'],
      ['Unidad (a-z)', 'unidad_asc']
    ]
  end

  def self.options_for_sorted_by_lots
    [
      ['Código (asc)', 'codigo_asc'],
      ['Nombre (a-z)', 'nombre_asc'],
      ['Unidad (a-z)', 'unidad_asc']
    ]
  end

  def refresh_quantity
    self.quantity = self.lot_stocks.sum(:quantity)
    self.total_quantity = self.lot_stocks.sum(:quantity) + self.lot_stocks.sum(:reserved_quantity)
    self.reserved_quantity = self.lot_stocks.sum(:reserved_quantity)
    self.save!
  end

  def create_stock_movement(an_order, a_lot_stock, a_quantity, adds_param, status)
    StockMovement.create(stock: self, order: an_order, lot_stock: a_lot_stock, quantity: a_quantity, adds: adds_param,
                         status: status)
  end

  def update_stock_movement(an_order, a_lot_stock, status)
    stock_movement = StockMovement.where(order_id: an_order.id, lot_stock: a_lot_stock.id).first
    stock_movement.update(status: status)
  end
end
