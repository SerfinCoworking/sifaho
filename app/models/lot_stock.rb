class LotStock < ApplicationRecord
  belongs_to :lot
  belongs_to :stock

  has_many :int_ord_prod_lot_stocks
  has_many :ext_ord_prod_lot_stocks
  has_many :out_pres_prod_lot_stocks
  has_many :chron_pres_prod_lot_stocks
  has_many :receipt_products
  has_many :lot_archives
  has_many :movements, class_name: "StockMovement", through: :stock

  has_one :sector, :through => :stock
  has_one :product, :through => :lot

  after_save :stock_refresh_quantity

  validates :quantity, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates_presence_of :stock_id
  
  delegate :refresh_quantity, to: :stock, prefix: true
  delegate :name, to: :product, prefix: true
  delegate :code, to: :lot, prefix: true

  filterrific(
    default_filter_params: { sorted_by: 'cantidad_desc' },
    available_filters: [
      :sorted_by,
    ]
  )

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^modificado_/s
      # Ordenamiento por fecha de creación en la BD
      reorder("lot_stocks.updated_at #{ direction }")
    when /^cantidad_/
      # Ordenamiento por la cantidad de stock
      reorder("lot_stocks.quantity #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :with_product, lambda { |a_product| 
    where('lot_stocks.product_id = ?', a_product.id).joins(:lot)
  }
  
  scope :with_status, lambda { |status| 
    where('lots.status = ?', status).joins(:lot)
  }

  scope :without_status, lambda { |a_status|
    where.not('lots.status = ?', a_status )
  }
  
  scope :lots_for_sector, lambda { |a_sector| 
    where(sector: a_sector)
  }
  
  scope :by_stock, lambda { |stock_id| 
    where(stock_id: stock_id)
  }

  # Método para incrementar la cantidad del lote. 
  # Si se encuentra archivado, vuelve a vigente con 0 de cantidad.
  def increment(a_quantity)
    self.quantity += a_quantity
    self.save!
  end
  
  # Disminuye la cantidad
  def decrement(a_quantity)
    if self.quantity < a_quantity
      raise ArgumentError, "Cantidad en stock insuficiente del lote "+self.lot_code+" insumo "+self.product_name
    else
      self.quantity -= a_quantity
      self.save!
    end
  end
end
