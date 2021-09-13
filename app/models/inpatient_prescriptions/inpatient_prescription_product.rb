class InpatientPrescriptionProduct < ApplicationRecord
  enum status: {
    sin_proveer: 0,
    provista: 1,
    parcialmente_suministrada: 2,
    suministrada: 3,
    terminada: 4
  }

  default_scope { joins(:product).order('products.name') }

  # Relationships
  has_many :order_prod_lot_stocks, dependent: :destroy, class_name: 'InPreProdLotStock',
                                   foreign_key: 'inpatient_prescription_product_id',
                                   source: :in_pre_prod_lot_stocks, inverse_of: 'inpatient_prescription_product'
  belongs_to :order, class_name: 'InpatientPrescription', foreign_key: 'inpatient_prescription_id',
                     inverse_of: 'order_products'
  belongs_to :prescribed_by, optional: true, class_name: 'User'
  belongs_to :delivered_by, optional: true, class_name: 'User'
  belongs_to :product
  has_many :lot_stocks, through: :order_prod_lot_stocks
  belongs_to :parent, class_name: 'InpatientPrescriptionProduct', required: false
  has_many :children, class_name: 'InpatientPrescriptionProduct', foreign_key: :parent_id

  # Validations
  validates :dose_quantity,
            numericality: { only_integer: true, greater_than: 0, message: 'Dosis debe ser mayor a 0' },
            if: :parent?
  validates :interval, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 24,
                                       message: 'Intervalo debe estar entre 1 y 24 hrs' }, if: :parent?
  validates :deliver_quantity,
            numericality: { only_integer: true, greater_than: 0, message: 'A entregar debe ser mayor a 0' },
            unless: :parent?
  validates_presence_of :product_id, message: 'Producto no puede estar en blanco'
  validates_presence_of :prescribed_by_id, if: :parent?
  validates_associated :order_prod_lot_stocks
  validate :uniqueness_parent_product_in_the_order, if: :parent?
  validate :uniqueness_child_product_in_the_order, if: :not_parent?

  accepts_nested_attributes_for :product,
                                allow_destroy: true
  accepts_nested_attributes_for :order_prod_lot_stocks,
                                reject_if: proc { |attributes| attributes['lot_stock_id'].blank? },
                                allow_destroy: true
  accepts_nested_attributes_for :children,
                                reject_if: proc { |attributes| attributes['lot_stock_id'].blank? },
                                allow_destroy: true

  # Delegations
  delegate :unity_name, :code, :name, to: :product, prefix: :product

  # Scopes
  scope :only_parents, -> { where(parent_id: :nil) }

  scope :for_statuses, ->(values) do
    return all if values.blank?

    where(status: statuses.values_at(*Array(values)))
  end

  scope :only_children, -> { where.not(parent_id: :nil) }

  def decrement_reserved_stock
    order_prod_lot_stocks.each(&:remove_reserved_quantity)
  end

  # Dispensamos la entrega de medicacion a un paciente en internacion
  # Marcamos "dispensada" parcialmente
  # Luego se llaman los productos que aun no fueron dispensados para decrementar el stock
  def dispensed_by(a_user)
    # Validamos que cada producto, tenga almenos 1 lote seleccionado
    children.each(&:validate_presence_of_order_prod_lot_stocks)
    # Validar que la cantidad a entregar sea igual a la seleccionada por la seleccion de lotes
    # (este debe controlarse al guardar la relacion)

    if children.any? { |child| child.errors.any? }
      raise ActiveRecord::RecordInvalid.new(self)
    elsif !children.any?
      errors.add(:presence_of_child, 'Debe asignar almenos 1 producto')
      raise ActiveRecord::RecordInvalid.new(self)
    else
      children.each(&:decrement_reserved_stock)
      self.status = 'provista'
      self.delivered_by_id = a_user.id
      save!(validate: false)
      notification_type = "entregó el producto #{product.name}"
      create_notification(a_user, notification_type, self)
    end
  end

  def added_by(a_user)
    self.prescribed_by = a_user
    notification_type = "agregó el producto #{product.name}"
    create_notification(a_user, notification_type, self)
  end

  # Validacion: evitar duplicidad de productos padres en una misma orden
  def validate_presence_of_order_prod_lot_stocks
    unless order_prod_lot_stocks.present?
      errors.add(:presence_of_order_prod_lot_stocks, 'Debe seleccionar almenos 1 lote')
    end
  end

  def create_notification(of_user, action_type, order_product = nil)
    InpatientPrescriptionMovement.create!(user: of_user, order: order, order_product: order_product,
                                          action: action_type, sector: of_user.sector)
    (of_user.sector.users.uniq - [of_user]).each do |user|
      @not = Notification.where(actor: of_user, user: user, target: order, notify_type: 'internacion',
                                action_type: action_type, actor_sector: of_user.sector).first_or_create
      @not.updated_at = DateTime.now
      @not.read_at = nil
      @not.save!
    end
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
    (parent.children.uniq - [self]).each do |eop|
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
