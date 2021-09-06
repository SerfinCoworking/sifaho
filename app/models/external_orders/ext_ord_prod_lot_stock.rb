class ExtOrdProdLotStock < ApplicationRecord

  include OrderProductLotStock

  belongs_to :external_order_product, inverse_of: 'order_prod_lot_stocks'
  has_one :order, through: :external_order_product, source: :external_order
  has_one :product, through: :external_order_product

  # Delegations
  delegate :code, to: :lot_stocks, prefix: :product

  private

  # Custom Validations
  def quantity_less_than_stock
    stock = lot_stock.quantity + reserved_quantity
    if stock < quantity && !inpatient_prescription_product.parent.provista?
      errors.add(:quantity, :less_than_or_equal_to,
                 message: "La cantidad seleccionada debe ser menor o igual a #{stock}")
    end
  end

  def quantity_greater_than_0
    if quantity.negative? && !inpatient_prescription_product.parent.provista?
      errors.add(:quantity, :greater_than, message: 'Cantidad debe ser mayor a 0')
    end
  end

  def total_quantity
    max_deliver_quantity = inpatient_prescription_product.order_prod_lot_stocks.sum(&:quantity)
    if inpatient_prescription_product.deliver_quantity != max_deliver_quantity
      errors.add(:total_quantity, message: "La cantidad seleccionada debe igual a #{inpatient_prescription_product.deliver_quantity}")
    end
  end
end

