class ChronicPrescriptionProduct < ApplicationRecord
  # Relationships
  belongs_to :original_chronic_prescription_product, inverse_of: 'chronic_prescription_products', optional: true
  belongs_to :product
  belongs_to :dispensation_type

  has_many :order_prod_lot_stocks, dependent: :destroy, class_name: 'ChronPresProdLotStock', foreign_key: 'chronic_prescription_product_id', source: :chron_pres_prod_lot_stocks, inverse_of: 'chronic_prescription_product'
  has_many :lot_stocks, through: :order_prod_lot_stocks

  # Validations
  validates :delivery_quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validate :out_of_stock, if: :is_dispensation?
  validate :lot_stock_sum_quantity, if: :is_dispensation?
  validates_presence_of :product_id
  validates :order_prod_lot_stocks, presence: { message: 'Debe seleccionar almenos 1 lote' }, if: :is_dispensation?
  validates_associated :order_prod_lot_stocks, if: :is_dispensation?
  validate :uniqueness_product_in_the_order
  validate :order_prod_lot_stocks_any_without_stock, if: :is_dispensation?
  validates_presence_of :original_chronic_prescription_product, if: :is_not_dispensation?

  accepts_nested_attributes_for :product,
                                allow_destroy: true
  accepts_nested_attributes_for :order_prod_lot_stocks,
                                allow_destroy: true

  # Delegations
  delegate :unity_name, :name, :code, to: :product, prefix: :product

  # custom validations
  def is_dispensation?
    return self.dispensation_type.chronic_dispensation.present? && self.dispensation_type.chronic_dispensation.pendiente?
  end

  def is_not_dispensation?
    return !self.dispensation_type.chronic_dispensation.present?
  end

  # Validacion: la cantidad no debe ser mayor o menor a la cantidad a entregar
  def lot_stock_sum_quantity
    total_quantity = 0
    self.order_prod_lot_stocks.each do |iopls| 
      total_quantity += iopls.quantity unless iopls.marked_for_destruction?
    end
    if self.delivery_quantity.present? && self.delivery_quantity < total_quantity
      errors.add(:quantity_lot_stock_sum, "El total de productos seleccionados no debe superar #{self.delivery_quantity}")
    end
    if self.delivery_quantity.present? && self.delivery_quantity > total_quantity
      errors.add(:quantity_lot_stock_sum, "El total de productos seleccionados debe ser igual a #{self.delivery_quantity}")
    end
  end

  # Validacion: evitar el envio de una orden si no tiene stock para enviar
  def out_of_stock
    total_stock = self.dispensation_type.chronic_dispensation.provider_sector.stocks.where(product_id: self.product_id).sum(:quantity)
    if self.delivery_quantity.present? && total_stock < self.delivery_quantity
      errors.add(:out_of_stock, "Este producto no tiene el stock necesario para entregar")
    end
  end


  # Validacion: evitar duplicidad de productos en una misma orden
  def uniqueness_product_in_the_order
    (self.dispensation_type.chronic_prescription_products.uniq - [self]).each do |iop| 
      if iop.product_id == self.product_id
        errors.add(:uniqueness_product_in_the_order, "Este producto ya se encuentra en la orden")      
      end
    end
  end

  # Validacion: algun lote que se este seleccionando una cantidad superior a la persistente
  def order_prod_lot_stocks_any_without_stock
    any_insufficient_lot_stock = self.order_prod_lot_stocks.any? do |opls|
      opls.errors[:quantity].any?
    end

    if any_insufficient_lot_stock
      errors.add(:order_prod_lot_stocks_any_without_stock, "Revisar las cantidades seleccionadas")      
    end
  end

  # Decrementamos la cantidad de cada lot stock (proveedor)
  def decrement_stock
    self.order_prod_lot_stocks.each do |cpp|
      cpp.lot_stock.decrement(cpp.quantity)
      cpp.lot_stock.stock.create_stock_movement(self.dispensation_type.chronic_dispensation.chronic_prescription, cpp.lot_stock, cpp.quantity, false)
    end
  end

  # Incrementamos la cantidad de cada lot stock (proveedor). Utilizado para retornar
  def increment_stock
    self.order_prod_lot_stocks.each do |cpp|
      cpp.lot_stock.increment(cpp.quantity, dispensation_type.chronic_dispensation.chronic_prescription)
    end
  end
end
