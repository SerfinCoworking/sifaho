class ChronPresProdLotStock < ApplicationRecord
  belongs_to :chronic_prescription_product, inverse_of: 'order_prod_lot_stocks'
  belongs_to :lot_stock
  has_one :order, through: :chronic_prescription_product, source: :chronic_prescription

  delegate :destiny_name, :origin_name, :status, to: :order

  def order_human_name
    self.order.class.model_name.human
  end

  def is_destiny?(a_sector)
    return false
  end
end
