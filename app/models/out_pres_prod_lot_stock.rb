class OutPresProdLotStock < ApplicationRecord
  belongs_to :outpatient_prescription_product, inverse_of: 'order_prod_lot_stocks'
  belongs_to :lot_stock

  validates :quantity, :numericality => { :only_integer => true, :less_than_or_equal_to => :lot_stock_quantity, message: "La cantidad seleccionada debe ser menor o igual a %{count}"}
  # validates :quantity, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }, if: :is_solicitud
  validates_presence_of :lot_stock_id

  accepts_nested_attributes_for :lot_stock,
    :allow_destroy => true

  delegate :code, to: :lot_stocks, prefix: :product
  
  def lot_stock_quantity
    return self.lot_stock.quantity
  end
      
  def is_solicitud
    return self.outpatient_prescription_product.outpatient_prescription.order_type == 'solicitud'
  end
end
