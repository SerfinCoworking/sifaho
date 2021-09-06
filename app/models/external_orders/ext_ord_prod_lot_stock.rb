class ExtOrdProdLotStock < ApplicationRecord
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
  validates :quantity, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }, if: :is_solicitud
  validates_presence_of :lot_stock_id

  accepts_nested_attributes_for :lot_stock,
    :allow_destroy => true

  # Delegations
  delegate :code, to: :lot_stocks, prefix: :product

  # Callbacks
  before_create :reserve_quantity
  before_update :update_reserved_quantity #, if: :product_is_not_dispensada?
  before_destroy :return_reserved_quantity

  def lot_stock_quantity
    return self.lot_stock.quantity
  end

  def is_provision
    return self.external_order_product.order.order_type == 'provision'
  end

  def is_solicitud
    return self.external_order_product.order.order_type == 'solicitud'
  end

  private

  def is_provider_accepted?
    return self.external_order_product.order.status == 'proveedor_aceptado'
  end

  

  def return_reserved_quantity
    lot_stock.enable_reserved(reserved_quantity)
  end

  # Decrementamos la cantidad reservada del stock
  # Quitamos el reserved_quantity de la relacion
  # def remove_reserved_quantity
  #   lot_stock.decrement_reserved(reserved_quantity)
  #   lot_stock.stock.create_stock_movement(inpatient_prescription_product.order, lot_stock, quanityty, false)
  #   update_columns(reserved_quantity: 0)
  # end

  # def product_is_not_dispensada?
  #   inpatient_prescription_product.parent.sin_proveer?
  # end

  # def order_product_is_parent?
  #   inpatient_prescription_product.parent_id.nil?
  # end

  # private

  def reserve_quantity
    lot_stock.reserve(quanityty)
    # igualamos lo solocitado con lo reservado
    self.reserved_quantity = quanityty
  end

  # Si se modifica la cantidad seleccionada del lote
  # se debe tener en cuenta la direfencia entre cantidad disponible
  # y cantidad reservada, para agregar o devolver stock reservado
  def update_reserved_quantity
    quantity = quanityty - reserved_quantity
    quantity.positive? ? lot_stock.reserve(quantity) : lot_stock.enable_reserved(quantity.abs)
    # igualamos lo solocitado con lo reservado
    self.reserved_quantity = quanityty
  end

  # Custom Validations
  def quantity_less_than_stock
    stock = lot_stock.quantity + reserved_quantity
    if stock < quanityty && !inpatient_prescription_product.parent.provista?
      errors.add(:quanityty, :less_than_or_equal_to,
                 message: "La cantidad seleccionada debe ser menor o igual a #{stock}")
    end
  end

  def quantity_greater_than_0
    if quanityty.negative? && !inpatient_prescription_product.parent.provista?
      errors.add(:quanityty, :greater_than, message: 'Cantidad debe ser mayor a 0')
    end
  end

  def total_quanityty
    max_deliver_quantity = inpatient_prescription_product.order_prod_lot_stocks.sum(&:quanityty)
    if inpatient_prescription_product.deliver_quantity != max_deliver_quantity
      errors.add(:total_quanityty, message: "La cantidad seleccionada debe igual a #{inpatient_prescription_product.deliver_quantity}")
    end
  end
end

