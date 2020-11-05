class ChronicPrescriptionProduct < ApplicationRecord
  # Relaciones
  belongs_to :chronic_prescription, inverse_of: 'chronic_prescription_products'
  belongs_to :product

  has_many :order_prod_lot_stocks, dependent: :destroy, class_name: "ChronPresProdLotStock", foreign_key: "chronic_prescription_product_id", source: :chron_pres_prod_lot_stocks, inverse_of: 'chronic_prescription_product'
  has_many :lot_stocks, :through => :order_prod_lot_stocks

  # Validaciones
  validates :request_quantity, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :delivery_quantity, :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }, if: proc { is_proveedor_auditoria? || is_proveedor_aceptado? } 
  validate :out_of_stock, if: :is_proveedor_aceptado?
  validate :lot_stock_sum_quantity, if: :is_provision? && :is_proveedor_aceptado?
  validates_presence_of :product_id
  validates :order_prod_lot_stocks, :presence => {:message => "Debe seleccionar almenos 1 lote"}, if: :is_proveedor_aceptado_and_quantity_greater_than_0?
  validates_associated :order_prod_lot_stocks, if: :is_proveedor_aceptado?
  validate :uniqueness_product_on_internal_order
  
  accepts_nested_attributes_for :product,
    :allow_destroy => true

  accepts_nested_attributes_for :order_prod_lot_stocks,
    :allow_destroy => true

  # Delegaciones
  delegate :unity, to: :product
  delegate :name, to: :product, prefix: :product
  delegate :code, to: :product, prefix: :product
end
