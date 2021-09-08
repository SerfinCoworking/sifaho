class ExternalOrderProduct < ApplicationRecord
  default_scope { joins(:product).order('products.name') }

  # Relaciones
  belongs_to :order, class_name: 'ExternalOrder', inverse_of: 'order_products'
  belongs_to :product
  belongs_to :added_by_sector, class_name: 'Sector'

  has_many :order_prod_lot_stocks, dependent: :destroy, class_name: 'ExtOrdProdLotStock', 
                                   foreign_key: 'order_product_id', source: :ext_ord_prod_lot_stocks,
                                   inverse_of: 'order_product'
  has_many :lot_stocks, through: :order_prod_lot_stocks

  # Validaciones
  validates :request_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :delivery_quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 },
                                if: proc { is_proveedor_auditoria? || is_proveedor_aceptado? }
  validate :out_of_stock, if: :is_proveedor_aceptado?
  validate :lot_stock_sum_quantity, if: :is_provision? && :is_proveedor_aceptado?
  validates_presence_of :product_id, :added_by_sector
  validates :order_prod_lot_stocks, presence: { message: 'Debe seleccionar almenos 1 lote'},
                                    if: :is_proveedor_aceptado_and_quantity_greater_than_0?
  validates_associated :order_prod_lot_stocks, if: :is_proveedor_aceptado?
  validate :uniqueness_product_in_the_order
  validate :order_prod_lot_stocks_any_without_stock

  accepts_nested_attributes_for :product,
                                allow_destroy: true
                                
  accepts_nested_attributes_for :order_prod_lot_stocks,
                                reject_if: proc { |attributes| attributes['lot_stock_id'].blank? },
                                allow_destroy: true
  # Delegaciones
  delegate :code, :name, :unity_name, to: :product, prefix: :product, allow_nil: true

  # Scopes
  scope :agency_referrals, -> (id, city_town) { includes(client: :address).where(agency_id: id, 'client.address.city_town' => city_town) }

  # Callbacks
  before_update :fill_delivery_quantity

  # new version
  def is_proveedor_auditoria?
    return order.proveedor_auditoria?
  end

  def is_proveedor_aceptado?
    return order.proveedor_aceptado?
  end

  def is_proveedor_aceptado_and_quantity_greater_than_0?
    return order.proveedor_aceptado? && (self.delivery_quantity.present? && self.delivery_quantity > 0)
  end

  def is_provision?
    return order.order_type == 'provision'
  end

  # Se habilita la cantidad que estaba reservada en stock
  def enable_reserved_stock
    self.order_prod_lot_stocks.each do |opls|
      opls.lot_stock.enable_reserved(opls.quantity)
    end
  end

  # Se reserva la cantidad del lote en stock
  def reserve_stock
    self.order_prod_lot_stocks.each do |opls|
      opls.lot_stock.reserve(opls.quantity)
    end
  end
  
  # Decrementamos la cantidad de cada lot stock (proveedor)
  def decrement_reserved_stock
    self.order_prod_lot_stocks.each do |opls|
      opls.lot_stock.decrement_reserved(opls.quantity)
      opls.lot_stock.stock.create_stock_movement(order, opls.lot_stock, opls.quantity, false)
    end
  end

  # Incrementamos la cantidad de cada lot stock (orden)
  def increment_stock
    self.order_prod_lot_stocks.each do |opls|
      opls.lot_stock.increment(opls.quantity)
      opls.lot_stock.stock.create_stock_movement(order, opls.lot_stock, opls.quantity, true)
    end
  end

  # Incrementamos la cantidad de lot stock (solicitante / desde una solicitud)
  def increment_lot_stock_to(a_sector)

    self.order_prod_lot_stocks.each do |opls|

      @stock = Stock.where(
        sector_id: a_sector.id,
        product_id: self.product_id
      ).first_or_create

      @lot_stock = LotStock.where(
        lot_id: opls.lot_stock.lot.id,
        stock_id: @stock.id,
      ).first_or_create

      @lot_stock.increment(opls.quantity)
      
      @stock.create_stock_movement(order, @lot_stock, opls.quantity, true)
    end
  end

  # custom validations
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

  # Validacion: evitar duplicidad de productos en una misma orden
  def uniqueness_product_in_the_order
    (order.order_products.uniq - [self]).each do |eop|
      if eop.product_id == self.product_id
        errors.add(:uniqueness_product_in_the_order, "El producto código ya se encuentra en la orden")      
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
  
  # Validacion: evitar el envio de una orden si no tiene stock para enviar
  def out_of_stock
    total_stock = order.provider_sector.stocks.where(product_id: self.product_id).sum(:quantity)
    if self.delivery_quantity.present? && total_stock < self.delivery_quantity
      errors.add(:out_of_stock, "Este producto no tiene el stock necesario para entregar")
    end
  end

  def get_order
    return order
  end

  def fill_delivery_quantity
    self.delivery_quantity = order_prod_lot_stocks.sum(&:quantity)
  end
end

