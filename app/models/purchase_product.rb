class PurchaseProduct < ApplicationRecord
  # Relaciones
  belongs_to :purchase, inverse_of: 'purchase_products'
  belongs_to :product

  has_many :order_prod_lot_stocks, dependent: :destroy, class_name: "PurchaseProdLotStock", foreign_key: "purchase_product_id", source: :purchase_prod_lot_stocks, inverse_of: 'purchase_product'
  has_many :lot_stocks, :through => :order_prod_lot_stocks

  # Atributos anidados
  accepts_nested_attributes_for :order_prod_lot_stocks,
    :allow_destroy => true
end
