class InternalOrderProduct < ApplicationRecord

  # Relaciones
  belongs_to :internal_order, inverse_of: 'internal_order_products'
  belongs_to :product

  has_many :order_prod_lot_stocks, dependent: :destroy, class_name: "IntOrdProdLotStock", foreign_key: "internal_order_product_id", source: :int_ord_prod_lot_stocks, inverse_of: 'internal_order_product'
  has_many :lot_stocks, :through => :order_prod_lot_stocks

  # Validaciones
  validates :request_quantity, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :delivery_quantity, :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }, if: proc { is_proveedor_auditoria? || is_provision_en_camino? } 
  validate :out_of_stock, if: :is_provision_en_camino?
  validate :lot_stock_sum_quantity, if: :is_provision? && :is_provision_en_camino?
  validates_presence_of :product_id
  validates :order_prod_lot_stocks, :presence => {:message => "Debe seleccionar almenos 1 lote"}, if: :is_provision_en_camino_and_quantity_greater_than_0?
  validates_associated :order_prod_lot_stocks, if: :is_provision_en_camino?
  validate :uniqueness_product_on_internal_order
  

  accepts_nested_attributes_for :product,
    :allow_destroy => true

  accepts_nested_attributes_for :order_prod_lot_stocks,
    :allow_destroy => true

  # Delegaciones
  delegate :unity, to: :product
  delegate :name, to: :product, prefix: :product
  delegate :code, to: :product, prefix: :product
  
  # Scopes
  scope :agency_referrals, -> (id, city_town) { includes(client: :address).where(agency_id: id, 'client.address.city_town' => city_town) }
  ###################### DEPRECATED ########################
  # scope :to_sector, lambda { |a_sector| joins(:sector_supply_lot).where(sector_supply_lots: { sector: a_sector }) }

  # scope :dispensed_since, lambda { |a_date| where('quantity_ord_supply_lots.dispensed_at >= ?', a_date) }
  # scope :dispensed_to, lambda { |a_date| where('quantity_ord_supply_lots.dispensed_at <= ?', a_date ) }

  # Métodos públicos

  # def increment_new_lot_to(a_sector)
  #   if self.lot_code.present? && self.laboratory_id.present?
  #     @supply_lot = SupplyLot.where(
  #       supply_id: self.supply_id,
  #       lot_code: self.lot_code,
  #       laboratory_id: self.laboratory_id,
  #     ).first_or_initialize
  #     @supply_lot.expiry_date = self.expiry_date
  #     @supply_lot.date_received = DateTime.now
  #     @supply_lot.save!
  #     @sector_supply_lot = SectorSupplyLot.where(
  #       sector_id: a_sector.id,
  #       supply_lot_id: @supply_lot.id
  #     ).first_or_create
  #     @sector_supply_lot.increment(self.delivered_quantity)
  #     self.dispensed_at = DateTime.now
  #     self.entregado!
  #   else
  #     raise ArgumentError, 'El insumo '+self.supply_name+' no tiene lote asignado.'
  #   end
  # end

  # Dispense supply of cronic prescription
  # def decrement_to_cronic(cronic_dispensation)
  #   if self.sector_supply_lot.present?
  #     if self.sector_supply_lot.decrement(self.delivered_quantity)
  #       new_qosl = self.dup  # Clone the actual QOSL
  #       new_qosl.save! # Save the clone
  #       self.cronic_dispensation = cronic_dispensation # Assign the current dispensation
  #       self.dispensed_at = DateTime.now
  #       self.entregado!
  #     end
  #   else
  #     cronic_dispensation.destroy
  #     raise ArgumentError, 'No hay lote asignado para '+self.supply_name
  #   end
  # end

  # Getter sector supply lot code
  # def sector_supply_lot_lot_code
  #   if self.sector_supply_lot.present?  
  #     self.sector_supply_lot.lot_code
  #   elsif self.lot_code.present?
  #     self.lot_code
  #   else
  #     'n/a'
  #   end
  # end

  # Getter sector supply lot expiry date
  # def sector_supply_lot_expiry_date
  #   if self.sector_supply_lot.present?
  #     self.sector_supply_lot.format_expiry_date
  #   elsif self.expiry_date.present?
  #     self.expiry_date.strftime('%m/%y')
  #   elsif self.lot_code.present?
  #     'No vence'
  #   else 
  #     'n/a'  
  #   end
  # end

  # Getter sector supply lot laboratory name
  # def sector_supply_lot_laboratory_name
  #   if self.sector_supply_lot.present?
  #     self.sector_supply_lot.laboratory
  #   elsif self.laboratory.present?
  #     self.laboratory.name
  #   else
  #     'n/a'
  #   end
  # end

  ############################### FIN DEPRECATED ################################

  # Return true if the order was delivered by the sector
  # def delivered_with_sector?(a_sector)
  #   self.quantifiable.delivered_with_sector?(a_sector)
  # end

  # Return true if the Ordering Supply is a "Recibo"
  # def quantifiable_is_recibo?
  #   if quantifiable.class.name == "ExternalOrder"
  #     return quantifiable.recibo?
  #   end 
  # end
  
  # Return all orders related to a sector and a supply code
  # def self.orders_to(a_sector, a_code)
  #   QuantityOrdSupplyLot.where.not(quantifiable: nil)
  #     .entregado
  #     .where(supply_id: a_code)
  #     .includes(:quantifiable)
  #     .select { |qosl| qosl.delivered_with_sector?(a_sector) }
  # end
  
  # new version
  def is_proveedor_auditoria?
    return self.internal_order.proveedor_auditoria?
  end
  
  def is_provision_en_camino?
    return self.internal_order.provision_en_camino?
  end

  def is_provision_en_camino_and_quantity_greater_than_0?
    return self.internal_order.provision_en_camino? && (self.delivery_quantity.present? && self.delivery_quantity > 0)
  end

  def is_provision?
    return self.internal_order.order_type == 'provision'
  end
  
  # Decrementamos la cantidad de cada lot stock (proveedor)
  def decrement_stock
    self.order_prod_lot_stocks.each do |iopls|
      iopls.lot_stock.decrement(iopls.quantity)
    end
  end

  # Incrementamos la cantidad de cada lot stock (orden)
  def increment_stock
    self.order_prod_lot_stocks.each do |iopls|
      iopls.lot_stock.increment(iopls.quantity)
    end
  end

  # Incrementamos la cantidad de lot stock (solicitante)
  def increment_lot_stock_to(a_sector)

    self.order_prod_lot_stocks.each do |iopls|

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
    self.order_prod_lot_stocks.each do |iopls| 
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
    (self.internal_order.internal_order_products.uniq - [self]).each do |iop| 
      if iop.product_id == self.product_id
        errors.add(:uniqueness_product_on_internal_order, "Este producto ya se encuentra en la orden")      
      end
    end
  end
  
  # Validacion: evitar el envio de una orden si no tiene stock para enviar
  def out_of_stock
    total_stock = self.internal_order.provider_sector.stocks.where(product_id: self.product_id).sum(:quantity)
    if self.delivery_quantity.present? && total_stock < self.delivery_quantity
      errors.add(:out_of_stock, "Este producto no tiene el stock necesario para entregar")
    end
  end

  def get_order
    return self.internal_order
  end

end

