class PurchaseProduct < ApplicationRecord
  # Relaciones
  belongs_to :purchase, inverse_of: 'purchase_products'
  belongs_to :product

  has_many :order_prod_lot_stocks, -> { order 'position DESC' }, dependent: :destroy, class_name: "PurchaseProdLotStock", foreign_key: "purchase_product_id", source: :purchase_prod_lot_stocks, inverse_of: 'purchase_product'
  has_many :lot_stocks, :through => :order_prod_lot_stocks

  validates_associated :order_prod_lot_stocks
  validates_presence_of :product_id
  validate :atleast_one_lot_selected
  # Atributos anidados
  accepts_nested_attributes_for :order_prod_lot_stocks,
    :allow_destroy => true

  # Validacion: evitar el envio de una orden si no tiene stock para enviar
  def atleast_one_lot_selected
    if self.order_prod_lot_stocks.size == 0
      errors.add(:atleast_one_lot_selected, "Debe seleccionar almenos 1 lote")
    end
  end
end
