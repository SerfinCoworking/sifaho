class PurchaseProdLotStock < ApplicationRecord
  belongs_to :purchase_product, inverse_of: 'order_prod_lot_stocks'
  # belongs_to :product, through: :purchase_product
  belongs_to :lot_stock, optional: true
  belongs_to :laboratory

  validates_presence_of :laboratory_id, :lot_code
  validates :quantity, presence: true, :numericality => { :only_integer => true }
  validates :presentation, presence: true, :numericality => { :only_integer => true }

  accepts_nested_attributes_for :lot_stock,
    :allow_destroy => true

  delegate :code, to: :lot_stocks, prefix: :product
  
  def lot_stock_quantity
    return self.lot_stock.quantity
  end
    
  def is_provision
    return self.external_order_product.external_order.order_type == 'provision'
  end
  
  def is_solicitud
    return self.external_order_product.external_order.order_type == 'solicitud'
  end
end
