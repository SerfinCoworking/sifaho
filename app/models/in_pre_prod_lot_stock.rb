class InPreProdLotStock < ApplicationRecord
  # Relations
  belongs_to :inpatient_prescription_product, inverse_of: 'order_prod_lot_stocks'
  belongs_to :lot_stock
  has_one :order, through: :inpatient_prescription_product, source: :inpatient_prescription
  has_one :product, through: :inpatient_prescription_product

  # Validations
  validates :available_quantity, 
  numericality: { 
    only_integer: true, 
    less_than_or_equal_to: :lot_stock_quantity, 
    message: "La cantidad seleccionada debe ser menor o igual a %{count}"
  }
  validates :available_quantity, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :lot_stock, presence: true

  accepts_nested_attributes_for :lot_stock,
    reject_if: proc { |attributes| attributes['lot_stock_id'].blank? },
    :allow_destroy => true

  def lot_stock_quantity
    return self.lot_stock.quantity
  end
end
