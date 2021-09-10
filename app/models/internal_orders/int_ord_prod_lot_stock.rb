class IntOrdProdLotStock < ApplicationRecord
  include OrderProductLotStock

  # Relationships
  belongs_to :order_product, inverse_of: 'order_prod_lot_stocks', class_name: 'InternalOrderProduct'
  has_one :order, through: :order_product, source: :internal_order
  has_one :product, through: :order_product

  # Decrement each order prod lot stock of a product
  def decrement_reserved_quantity
    lot_stock.decrement_reserved(reserved_quantity)
    lot_stock.stock.create_stock_movement(order_product.order, lot_stock, quantity, false)
    update_column(:reserved_quantity, 0)
  end
end
