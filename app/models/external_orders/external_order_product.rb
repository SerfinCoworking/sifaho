class ExternalOrderProduct < ApplicationRecord

  
  default_scope { joins(:product).order('products.name') }
  
  # Relationships
  belongs_to :order, class_name: 'ExternalOrder', inverse_of: 'order_products'
  belongs_to :added_by_sector, class_name: 'Sector'
  has_many :order_prod_lot_stocks, dependent: :destroy, class_name: 'ExtOrdProdLotStock', 
  foreign_key: 'order_product_id', source: :ext_ord_prod_lot_stocks,
  inverse_of: 'order_product'
  has_many :lot_stocks, through: :order_prod_lot_stocks

  include OrderProduct

  # Validaciones
  validates :delivery_quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 },
                                if: proc { is_proveedor_auditoria? || is_proveedor_aceptado? }
  validate :out_of_stock, if: :is_proveedor_aceptado?
  validate :lot_stock_sum_quantity, if: :is_provision? && :is_proveedor_aceptado?
  
  validates :order_prod_lot_stocks, presence: { message: 'Debe seleccionar almenos 1 lote'},
                                    if: :is_proveedor_aceptado_and_quantity_greater_than_0?
  validates_associated :order_prod_lot_stocks, if: :is_proveedor_aceptado?

  # Scopes
  scope :agency_referrals, -> (id, city_town) { includes(client: :address).where(agency_id: id, 'client.address.city_town' => city_town) }

  # new version
  def is_proveedor_auditoria?
    return order.proveedor_auditoria?
  end

  def is_proveedor_aceptado?
    return order.proveedor_aceptado?
  end

  def is_proveedor_aceptado_and_quantity_greater_than_0?
    return order.proveedor_aceptado? && (self.delivery_quantity.present? && self.delivery_quantity > 0)
  end

  def is_provision?
    return order.order_type == 'provision'
  end

  # Se habilita la cantidad que estaba reservada en stock
  def enable_reserved_stock
    self.order_prod_lot_stocks.each do |opls|
      opls.lot_stock.enable_reserved(opls.quantity)
    end
  end

  # Se reserva la cantidad del lote en stock
  def reserve_stock
    self.order_prod_lot_stocks.each do |opls|
      opls.lot_stock.reserve(opls.quantity)
    end
  end
  
  # Decrementamos la cantidad de cada lot stock (proveedor)
  def decrement_reserved_stock
    self.order_prod_lot_stocks.each do |opls|
      opls.lot_stock.decrement_reserved(opls.quantity)
      opls.lot_stock.stock.create_stock_movement(order, opls.lot_stock, opls.quantity, false)
    end
  end

end

