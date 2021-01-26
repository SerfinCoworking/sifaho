class IntOrdProdLotStock < ApplicationRecord
  belongs_to :internal_order_product, inverse_of: 'order_prod_lot_stocks'
  has_one :order, through: :internal_order_product, source: :internal_order
  belongs_to :lot_stock

  validates :quantity, :numericality => { :only_integer => true, :less_than_or_equal_to => :lot_stock_quantity, message: "La cantidad seleccionada debe ser menor o igual a %{count}"}, if: :is_provision
  validates :quantity, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }, if: :is_solicitud
  validates_presence_of :lot_stock_id

  accepts_nested_attributes_for :lot_stock,
    :allow_destroy => true

  delegate :code, to: :lot_stocks, prefix: :product
  delegate :destiny_name, :origin_name, :status, to: :order
  
  def lot_stock_quantity
    return self.lot_stock.quantity
  end
    
  def is_provision
    return self.internal_order_product.internal_order.order_type == 'provision'
  end
  
  def is_solicitud
    return self.internal_order_product.internal_order.order_type == 'solicitud'
  end
  
  def order_human_name
    self.order.class.model_name.human
  end

  def is_destiny?(a_sector)
    return self.order.applicant_sector == a_sector
  end
end
