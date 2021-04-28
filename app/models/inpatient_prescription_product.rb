class InpatientPrescriptionProduct < ApplicationRecord

  enum status: { 
    activo: 0,
    terminado: 1,
    suspendido: 2
  }

  default_scope { joins(:product).order("products.name") }

  # Relaciones
  has_many :order_prod_lot_stocks, dependent: :destroy, class_name: "InPreProdLotStock", foreign_key: "inpatient_prescription_product_id", source: :in_pre_prod_lot_stocks, inverse_of: 'inpatient_prescription_product'
  belongs_to :inpatient_prescription, inverse_of: 'order_products'
  belongs_to :product
  has_many :lot_stocks, :through => :order_prod_lot_stocks

  # Validaciones
  validates :dose_quantity, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates_presence_of :product_id
  # validates :order_prod_lot_stocks, :presence => {:message => "Debe seleccionar almenos 1 lote"}, if: :is_proveedor_aceptado_and_quantity_greater_than_0?
  # validates_associated :order_prod_lot_stocks, if: :is_proveedor_aceptado?
  validate :uniqueness_product_in_the_order

  delegate :code, :name, to: :product, prefix: :product
  
  def get_order
    return self.inpatient_prescription
  end

  private

    # Validacion: evitar duplicidad de productos en una misma orden
    def uniqueness_product_in_the_order
      (self.inpatient_prescription.order_products.uniq - [self]).each do |eop|
        if eop.product_id == self.product_id
          errors.add(:uniqueness_product_in_the_order, "El producto código ya se encuentra en la orden")      
        end
      end
    end
  
end
