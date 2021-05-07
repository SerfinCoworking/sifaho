class ChronPresProdLotStock < ApplicationRecord
  belongs_to :chronic_prescription_product, inverse_of: 'order_prod_lot_stocks'
  belongs_to :lot_stock
  has_one :order, through: :chronic_prescription_product, source: :chronic_prescription

  delegate :destiny_name, :origin_name, :status, to: :order

  # Validations
  validates :quantity, 
    numericality: { 
      only_integer: true, 
      less_than_or_equal_to: :lot_stock_quantity, 
      message: "La cantidad seleccionada debe ser menor o igual a %{count}"
    }

  validates_presence_of :lot_stock_id

  accepts_nested_attributes_for :lot_stock,
    :allow_destroy => true

  def lot_stock_quantity
    return self.lot_stock.quantity
  end
end
