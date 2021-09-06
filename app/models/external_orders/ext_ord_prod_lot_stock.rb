class ExtOrdProdLotStock < ApplicationRecord

  include OrderProductLotStock

  belongs_to :external_order_product, inverse_of: 'order_prod_lot_stocks'
  has_one :order, through: :external_order_product, source: :external_order
  has_one :product, through: :external_order_product

  # Delegations
  delegate :code, to: :lot_stocks, prefix: :product


end

