class LotStock < ApplicationRecord
  belongs_to :lot
  belongs_to :stock

  has_many :int_ord_prod_lot_stocks
  has_many :ext_ord_prod_lot_stocks
  has_many :out_pres_prod_lot_stocks
  has_many :chron_pres_prod_lot_stocks
  has_many :receipt_products

  has_one :sector, :through => :stock
  has_one :product, :through => :lot

  after_save :stock_refresh_quantity

  validates :quantity, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates_presence_of :stock_id
  
  delegate :refresh_quantity, to: :stock, prefix: true
  delegate :name, to: :product, prefix: true
  delegate :code, to: :lot, prefix: true

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

  # Return all merged movements relationships
  def movements
    return self.int_ord_prod_lot_stocks +
      self.ext_ord_prod_lot_stocks +
      self.out_pres_prod_lot_stocks +
      self.chron_pres_prod_lot_stocks +
      self.receipt_products
  end

  # Return count movements
  def movements_count
    return self.int_ord_prod_lot_stocks.count +
      self.ext_ord_prod_lot_stocks.count +
      self.out_pres_prod_lot_stocks.count +
      self.chron_pres_prod_lot_stocks.count +
      self.receipt_products.count
  end
end
