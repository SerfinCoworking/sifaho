class InpatientPrescriptionProduct < ApplicationRecord

  enum status: {
    sin_proveer: 0,
    provista: 1,
    parcialmente_suministrada: 2,
    suministrada: 3,
    terminada: 4
  }

  default_scope { joins(:product).order('products.name') }

  # Relaciones
  has_many :order_prod_lot_stocks, dependent: :destroy, class_name: 'InPreProdLotStock',
                                   foreign_key: 'inpatient_prescription_product_id',
                                   source: :in_pre_prod_lot_stocks, inverse_of: 'inpatient_prescription_product'
  belongs_to :order, class_name: 'InpatientPrescription', foreign_key: 'inpatient_prescription_id',
                     inverse_of: 'order_products'
  belongs_to :product
  has_many :lot_stocks, through: :order_prod_lot_stocks
  belongs_to :parent, class_name: 'InpatientPrescriptionProduct', required: false
  has_many :children, class_name: 'InpatientPrescriptionProduct', foreign_key: :parent_id

  # Validaciones
  validates :dose_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, if: :parent?
  validates_presence_of :product_id
  # validates :order_prod_lot_stocks, :presence => {:message => "Debe seleccionar almenos 1 lote"},
  # if: :is_proveedor_aceptado_and_quantity_greater_than_0?

  validates_associated :order_prod_lot_stocks
  validate :uniqueness_parent_product_in_the_order, if: :parent?
  validate :uniqueness_child_product_in_the_order, if: :not_parent?

  delegate :code, :name, to: :product, prefix: :product

  accepts_nested_attributes_for :product,
                                allow_destroy: true

  accepts_nested_attributes_for :order_prod_lot_stocks,
                                reject_if: proc { |attributes| attributes['lot_stock_id'].blank? },
                                allow_destroy: true

  accepts_nested_attributes_for :children,
                                reject_if: proc { |attributes| attributes['lot_stock_id'].blank? },
                                allow_destroy: true

  scope :only_parents, -> { where(parent_id: :nil) }
  scope :only_children, -> { where.not(parent_id: :nil) }

  # Decrementamos el stock de cada producto asignado al parent
  def decrement_stock
    children.each(&:decrement_reserved_stock)
  end

  def decrement_reserved_stock
    parent.update!(status: :provista) if order_prod_lot_stocks.count.positive?
    order_prod_lot_stocks.each(&:remove_reserved_quantity)
  end

  private

  # Validacion: evitar duplicidad de productos padres en una misma orden
  def uniqueness_parent_product_in_the_order
    (order.parent_order_products.uniq - [self]).each do |eop|
      if eop.product_id == product_id
        errors.add(:uniqueness_parent_product_in_the_order, 'El producto ya se encuentra en la orden')
      end
    end
  end

  # Validacion: evitar duplicidad de productos hijos en una misma orden
  def uniqueness_child_product_in_the_order
    (order.order_products.uniq - [self]).each do |eop|
      if eop.product_id == product_id
        errors.add(:uniqueness_child_product_in_the_order, 'El producto ya se encuentra en la entrega')
      end
    end
  end

  def not_parent?
    !parent?
  end

  def parent?
    parent.nil?
  end

end
