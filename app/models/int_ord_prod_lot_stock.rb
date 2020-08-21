class IntOrdProdLotStock < ApplicationRecord
  belongs_to :internal_order_products
  belongs_to :lot_stock


  validates :quantity, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates_presence_of :lot_stock_id

  accepts_nested_attributes_for :lot_stock,
    :allow_destroy => true

  delegate :code, to: :lot_stocks, prefix: :product
end
