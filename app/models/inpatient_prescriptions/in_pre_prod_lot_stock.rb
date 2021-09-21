class InPreProdLotStock < ApplicationRecord
  # Relations
  belongs_to :inpatient_prescription_product, inverse_of: 'order_prod_lot_stocks'
  belongs_to :lot_stock
  has_one :order, through: :inpatient_prescription_product, source: :inpatient_prescription
  has_one :product, through: :inpatient_prescription_product

  # Validations
  validate :quantity_greater_than_0, unless: :order_product_is_parent?
  validate :quantity_less_than_stock, unless: :order_product_is_parent?
  validates :lot_stock, presence: true
  validate :total_available_quantity

  before_create :reserve_quantity
  before_update :update_reserved_quantity, if: :product_is_not_dispensada?
  before_destroy :return_reserved_quantity

  def return_reserved_quantity
    lot_stock.enable_reserved(reserved_quantity)
  end

  # Decrementamos la cantidad reservada del stock
  # Quitamos el reserved_quantity de la relacion
  def remove_reserved_quantity
    lot_stock.decrement_reserved(reserved_quantity)
    lot_stock.stock.create_stock_movement(inpatient_prescription_product.order, lot_stock, available_quantity, false)
    update_columns(reserved_quantity: 0)
  end

  def product_is_not_dispensada?
    inpatient_prescription_product.parent.sin_proveer?
  end

  def order_product_is_parent?
    inpatient_prescription_product.parent_id.nil?
  end

  private

  def reserve_quantity
    lot_stock.reserve(available_quantity)
    # igualamos lo solocitado con lo reservado
    self.reserved_quantity = available_quantity
  end

  # Si se modifica la cantidad seleccionada del lote
  # se debe tener en cuenta la direfencia entre cantidad disponible
  # y cantidad reservada, para agregar o devolver stock reservado
  def update_reserved_quantity
    quantity = available_quantity - reserved_quantity
    quantity.positive? ? lot_stock.reserve(quantity) : lot_stock.enable_reserved(quantity.abs)
    # igualamos lo solocitado con lo reservado
    self.reserved_quantity = available_quantity
  end

  def quantity_less_than_stock
    stock = lot_stock.quantity + reserved_quantity
    if stock < available_quantity && !inpatient_prescription_product.parent.provista?
      errors.add(:available_quantity, :less_than_or_equal_to,
                 message: "La cantidad seleccionada debe ser menor o igual a #{stock}")
    end
  end

  def quantity_greater_than_0
    if available_quantity.negative? && !inpatient_prescription_product.parent.provista?
      errors.add(:available_quantity, :greater_than, message: 'Cantidad debe ser mayor a 0')
    end
  end

  def total_available_quantity
    max_deliver_quantity = inpatient_prescription_product.order_prod_lot_stocks.sum(&:available_quantity)
    if inpatient_prescription_product.deliver_quantity != max_deliver_quantity
      errors.add(:total_available_quantity, message: "La cantidad seleccionada debe igual a #{inpatient_prescription_product.deliver_quantity}")
    end
  end
end
