class OutpatientPrescriptionProduct < ApplicationRecord

  # Relaciones
  belongs_to :outpatient_prescription, inverse_of: 'outpatient_prescription_products'
  belongs_to :product

  has_many :order_prod_lot_stocks, dependent: :destroy, class_name: "OutPresProdLotStock", foreign_key: "outpatient_prescription_product_id", source: :out_pres_prod_lot_stocks, inverse_of: 'outpatient_prescription_product'
  has_many :lot_stocks, :through => :order_prod_lot_stocks

  # Validaciones
  validates :request_quantity, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :delivery_quantity, :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }, if: :is_pending? 
  validate :out_of_stock, if: :is_provision_dispensed?
  validate :lot_stock_sum_quantity, if: :is_provision_dispensed?
  validates_presence_of :product_id
  validates :order_prod_lot_stocks, :presence => {:message => "Debe seleccionar almenos 1 lote"}, if: :is_dispensed_and_quantity_greater_than_0?
  validates_associated :order_prod_lot_stocks, if: :is_provision_dispensed?
  validate :uniqueness_product_on_outpatient_prescription
  

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
    
  # new version
  def is_pending?
    return self.outpatient_prescription.pendiente?
  end
  
  def is_provision_dispensed?
    return self.outpatient_prescription.dispensada?
  end

  def is_dispensed_and_quantity_greater_than_0?
    return self.is_provision_dispensed? && (self.delivery_quantity.present? && self.delivery_quantity > 0)
  end

  # Decrementamos la cantidad de cada lot stock (proveedor)
  def decrement_stock
    self.order_prod_lot_stocks.each do |oppls|
      oppls.lot_stock.decrement(oppls.quantity)
    end
  end

  # Incrementamos la cantidad de cada lot stock (orden)
  def increment_stock
    self.order_prod_lot_stocks.each do |oppls|
      oppls.lot_stock.increment(oppls.quantity)
    end
  end

  # custom validations
  # Validacion: la cantidad no debe ser mayor o menor a la cantidad a entregar
  def lot_stock_sum_quantity
    total_quantity = 0
    self.order_prod_lot_stocks.each do |oppls| 
      total_quantity += oppls.quantity
    end
    if self.delivery_quantity.present? && self.delivery_quantity < total_quantity
      errors.add(:quantity_lot_stock_sum, "El total de productos seleccionados no debe superar #{self.delivery_quantity}")
    end
    
    if self.delivery_quantity.present? && self.delivery_quantity > total_quantity
      errors.add(:quantity_lot_stock_sum, "El total de productos seleccionados debe ser igual a #{self.delivery_quantity}")
    end
  end

  # Validacion: evitar duplicidad de productos en una misma orden
  def uniqueness_product_on_outpatient_prescription
    (self.outpatient_prescription.outpatient_prescription_products.uniq - [self]).each do |opp| 
      if opp.product_id == self.product_id
        errors.add(:uniqueness_product_on_outpatient_prescription, "Este producto ya se encuentra en la orden")      
      end
    end
  end
  
  # Validacion: evitar la dispensacion de una orden si no tiene stock para dispensar
  def out_of_stock
    total_stock = self.outpatient_prescription.provider_sector.stocks.where(product_id: self.product_id).sum(:quantity)
    if self.delivery_quantity.present? && total_stock < self.delivery_quantity
      errors.add(:out_of_stock, "Este producto no tiene el stock necesario para entregar")
    end
  end

  def get_order
    return self.outpatient_prescription
  end
end
