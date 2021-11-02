class InternalOrderProduct < ApplicationRecord

  # Relationships
  belongs_to :order, class_name: 'InternalOrder', inverse_of: 'order_products'
  belongs_to :added_by_sector, class_name: 'Sector'
  has_many :order_prod_lot_stocks, dependent: :destroy, class_name: 'IntOrdProdLotStock',
           foreign_key: 'order_product_id', source: :int_ord_prod_lot_stocks,
           inverse_of: 'order_product'
  has_many :lot_stocks, through: :order_prod_lot_stocks

  include OrderProduct

  
  # Validations
  validates :delivery_quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 },
                                if: proc { is_proveedor_auditoria? || is_provision_en_camino? }
  validate :out_of_stock, if: :is_provision_en_camino?
  validate :lot_stock_sum_quantity, if: :is_provision? && :is_provision_en_camino?
  validates :order_prod_lot_stocks, presence: { message: 'Debe seleccionar almenos 1 lote' },
                                    if: :is_provision_en_camino_and_quantity_greater_than_0?
  validates_associated :order_prod_lot_stocks, if: :is_provision_en_camino?

  # Scopes
  scope :agency_referrals, -> (id, city_town) { includes(client: :address).where(agency_id: id, 'client.address.city_town' => city_town) }

  scope :ordered_products, -> { joins(:product).order('products.name DESC') }

  # new version
  def is_proveedor_auditoria?
    return order.proveedor_auditoria?
  end

  def is_provision_en_camino?
    return order.provision_en_camino?
  end

  def is_provision_en_camino_and_quantity_greater_than_0?
    return order.provision_en_camino? && (self.delivery_quantity.present? && self.delivery_quantity > 0)
  end

  def is_provision?
    return order.order_type == 'provision'
  end
end
