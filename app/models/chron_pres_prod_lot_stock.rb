class ChronPresProdLotStock < ApplicationRecord
  belongs_to :chronic_prescription_product, inverse_of: 'order_prod_lot_stocks'
  belongs_to :lot_stock
end
