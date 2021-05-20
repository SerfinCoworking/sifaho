class InPreProdLotStock < ApplicationRecord
  # Relations
  belongs_to :inpatient_prescription_product, inverse_of: 'order_prod_lot_stocks'
  belongs_to :lot_stock
  has_one :order, through: :inpatient_prescription_product, source: :inpatient_prescription
  has_one :product, through: :inpatient_prescription_product

  # Validations
  # validates :available_quantity, 
  # numericality: { 
  #   only_integer: true, 
  #   less_than_or_equal_to: :lot_stock_quantity, 
  #   message: "La cantidad seleccionada debe ser menor o igual a %{count}"
  # }
  # validates :available_quantity, :numericality => { :only_integer => true, :greater_than => 0 }
  validate :quantity_greater_than_0
  validate :quantity_less_than_stock
  validates :lot_stock, presence: true

  accepts_nested_attributes_for :lot_stock,
    reject_if: proc { |attributes| attributes['lot_stock_id'].blank? },
    :allow_destroy => true

  before_create :reserve_quantity
  before_update :update_reserved_quantity
  before_destroy :remove_reserved_quantity

  def lot_stock_quantity
    return self.lot_stock.quantity
  end

  private
    
  def reserve_quantity
    self.lot_stock.reserve(self.available_quantity)
    self.reserved_quantity = self.available_quantity #igualamos lo solocitado con lo reservado
  end
  
  def update_reserved_quantity
    quantity = self.available_quantity - self.reserved_quantity
    quantity > 0 ? self.lot_stock.reserve(quantity) : self.lot_stock.enable_reserved(quantity.abs)
    self.reserved_quantity = self.available_quantity #igualamos lo solocitado con lo reservado
  end
  
  def remove_reserved_quantity
    self.lot_stock.enable_reserved(self.reserved_quantity)
  end
  
  def quantity_less_than_stock
    stock = self.lot_stock.quantity + self.reserved_quantity
    errors.add(:available_quantity, :less_than_or_equal_to, message: "La cantidad seleccionada debe ser menor o igual a #{stock}") unless stock >= self.available_quantity 
  end
  
  def quantity_greater_than_0
    errors.add(:available_quantity, :greater_than, message: "Cantidad debe ser mayor a 0") unless self.available_quantity > 0 
  end
end
