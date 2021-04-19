class InPreProdLotStock < ApplicationRecord
  # Relations
  belongs_to :inpatient_prescription_product, inverse_of: 'order_prod_lot_stocks'
  belongs_to :lot_stock
  has_one :order, through: :inpatient_prescription_product, source: :inpatient_prescription
  has_one :product, through: :inpatient_prescription_product
  belongs_to :dispensed_by

  # Validations
  validates :quantity, 
  numericality: { 
    only_integer: true, 
    less_than_or_equal_to: :lot_stock_quantity, 
    message: "La cantidad seleccionada debe ser menor o igual a %{count}"
  },
  if: :is_provider_accepted?
  validates :quantity, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :lot_stock, presence: true
end
