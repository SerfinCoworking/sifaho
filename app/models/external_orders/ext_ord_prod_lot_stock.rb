class ExtOrdProdLotStock < ApplicationRecord

  include OrderProductLotStock

  belongs_to :order_product, inverse_of: 'order_prod_lot_stocks', class_name: 'ExternalOrderProduct'
  has_one :order, through: :order_product, source: :external_order
  has_one :product, through: :order_product

  # Delegations
  delegate :code, to: :lot_stocks, prefix: :product
end
