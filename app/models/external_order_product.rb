class ExternalOrderProduct < ApplicationRecord

  # Relaciones
  belongs_to :external_order
  belongs_to :product

  has_many :ext_ord_prod_lot_stocks, dependent: :destroy
  has_many :lot_stocks, :through => :ext_ord_prod_lot_stocks

  # Validaciones
  validates :request_quantity, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :delivery_quantity, :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }, if: proc { is_proveedor_auditoria? || is_provision_en_camino? } 
  validate :out_of_stock, if: :is_provision_en_camino?
  validate :lot_stock_sum_quantity, if: :is_provision? && :is_provision_en_camino?
  validates_presence_of :product_id
  validates :ext_ord_prod_lot_stocks, :presence => {:message => "Debe seleccionar almenos 1 lote"}, if: :is_provision_en_camino_and_quantity_greater_than_0?
  validates_associated :ext_ord_prod_lot_stocks, if: :is_provision_en_camino?
  validate :uniqueness_product_on_internal_order
  

  accepts_nested_attributes_for :product,
    :allow_destroy => true

  accepts_nested_attributes_for :ext_ord_prod_lot_stocks,
    :allow_destroy => true

  # Delegaciones
  delegate :unity, to: :product
  delegate :name, to: :product, prefix: :product
  delegate :code, to: :product, prefix: :product
  
  # Scopes
  scope :agency_referrals, -> (id, city_town) { includes(client: :address).where(agency_id: id, 'client.address.city_town' => city_town) }
  
  # new version
  def is_proveedor_auditoria?
    return self.external_order.proveedor_auditoria?
  end
  
  def is_provision_en_camino?
    return self.external_order.provision_en_camino?
  end

  def is_provision_en_camino_and_quantity_greater_than_0?
    return self.external_order.provision_en_camino? && (self.delivery_quantity.present? && self.delivery_quantity > 0)
  end

  def is_provision?
    return self.external_order.order_type == 'provision'
  end
  
  # Decrementamos la cantidad de cada lot stock (proveedor)
  def decrement_stock
    self.ext_ord_prod_lot_stocks.each do |iopls|
      iopls.lot_stock.decrement(iopls.quantity)
    end
  end

  # Incrementamos la cantidad de cada lot stock (orden)
  def increment_stock
    self.ext_ord_prod_lot_stocks.each do |iopls|
      iopls.lot_stock.increment(iopls.quantity)
    end
  end

  # Incrementamos la cantidad de lot stock (solicitante)
  def increment_lot_stock_to(a_sector)

    self.ext_ord_prod_lot_stocks.each do |iopls|

      @stock = Stock.where(
        sector_id: a_sector.id,
        product_id: self.product_id
      ).first_or_create

      @lot_stock = LotStock.where(
        lot_id: iopls.lot_stock.lot.id,
        stock_id: @stock.id,
      ).first_or_create

      @lot_stock.increment(iopls.quantity)
    end
  end

  # custom validations
  # Validacion: la cantidad no debe ser mayor o menor a la cantidad a entregar
  def lot_stock_sum_quantity
    total_quantity = 0
    self.ext_ord_prod_lot_stocks.each do |iopls| 
      total_quantity += iopls.quantity
    end
    if self.delivery_quantity.present? && self.delivery_quantity < total_quantity
      errors.add(:quantity_lot_stock_sum, "El total de productos seleccionados no debe superar #{self.delivery_quantity}")
    end
    
    if self.delivery_quantity.present? && self.delivery_quantity > total_quantity
      errors.add(:quantity_lot_stock_sum, "El total de productos seleccionados debe ser igual a #{self.delivery_quantity}")
    end
  end

  # Validacion: evitar duplicidad de productos en una misma orden
  def uniqueness_product_on_internal_order
    (self.external_order.external_order_products.uniq - [self]).each do |iop| 
      if iop.product_id == self.product_id
        errors.add(:uniqueness_product_on_internal_order, "Este producto ya se encuentra en la orden")      
      end
    end
  end
  
  # Validacion: evitar el envio de una orden si no tiene stock para enviar
  def out_of_stock
    total_stock = self.external_order.provider_sector.stocks.where(product_id: self.product_id).sum(:quantity)
    if self.delivery_quantity.present? && total_stock < self.delivery_quantity
      errors.add(:out_of_stock, "Este producto no tiene el stock necesario para entregar")
    end
  end

end

