class IntOrdProdLotStock < ApplicationRecord
  include OrderProductLotStock

  # Relationships
  belongs_to :order_product, inverse_of: 'order_prod_lot_stocks', class_name: 'InternalOrderProduct'
  has_one :order, through: :order_product, source: :internal_order
  has_one :product, through: :order_product
end
