class OutPresProdLotStock < ApplicationRecord
  belongs_to :outpatient_prescription_product, inverse_of: 'order_prod_lot_stocks'
  belongs_to :lot_stock
  has_one :order, through: :outpatient_prescription_product, source: :outpatient_prescription

  validates :quantity, :numericality => { :only_integer => true, :less_than_or_equal_to => :lot_stock_quantity, message: "La cantidad seleccionada debe ser menor o igual a %{count}"}
  validates_presence_of :lot_stock_id

  accepts_nested_attributes_for :lot_stock,
    :allow_destroy => true

  delegate :code, to: :lot_stocks, prefix: :product
  delegate :destiny_name, :origin_name, :status, to: :order

  def lot_stock_quantity
    return self.lot_stock.quantity
  end
  
  def order_human_name
    self.order.class.model_name.human
  end

  def is_destiny?(a_sector)
    return false
  end
end
