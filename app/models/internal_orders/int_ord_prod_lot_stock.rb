class IntOrdProdLotStock < ApplicationRecord
  include OrderProductLotStock

  # Relationships
  belongs_to :internal_order_product, inverse_of: 'order_prod_lot_stocks'
  has_one :order, through: :internal_order_product, source: :internal_order
  has_one :product, through: :internal_order_product
end
