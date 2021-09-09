class ExtOrdProdLotStock < ApplicationRecord

  # Relationships
  belongs_to :external_order_product, inverse_of: 'order_prod_lot_stocks'
  has_one :order, through: :external_order_product, source: :external_order
  has_one :product, through: :external_order_product
  belongs_to :lot_stock

  # Validations
  validates :quantity,
            numericality: {
              only_integer: true,
              less_than_or_equal_to: :lot_stock_quantity,
              message: "La cantidad seleccionada debe ser menor o igual a %{count}"
            },
            if: :is_provider_accepted?
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, if: :is_solicitud
  validates_presence_of :lot_stock_id

  accepts_nested_attributes_for :lot_stock,
                                allow_destroy: true

  # Delegations
  delegate :code, to: :lot_stocks, prefix: :product
  delegate :quantity, to: :lot_stock, prefix: true, allow_nil: true

  def is_provision
    external_order_product.external_order.order_type == 'provision'
  end

  def is_solicitud
    external_order_product.external_order.order_type == 'solicitud'
  end

  private

  def is_provider_accepted?
    external_order_product.external_order.status == 'proveedor_aceptado'
  end
end
