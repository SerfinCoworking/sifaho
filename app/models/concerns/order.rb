module Order
  extend ActiveSupport::Concern

  included do

    # Relationships
    belongs_to :applicant_sector, class_name: 'Sector'
    belongs_to :provider_sector, class_name: 'Sector'
    has_many :lot_stocks, through: :order_products
    has_many :lots, through: :lot_stocks
    has_many :products, through: :order_products

    # Validations
    validates_presence_of :provider_sector_id, :applicant_sector_id, :requested_date, :remit_code
    validates_uniqueness_of :remit_code

    # Callbacks
    before_validation :record_remit_code, on: :create

    # Delegations
    delegate :name, to: :provider_sector, prefix: true

    # Cambia estado a "en camino" y descuenta la cantidad a los lotes de insumos
    def send_order_by(a_user)
      self.order_products.with_delivery_quantity.each(&:send_products)
      self.status = 'provision_en_camino'
      self.sent_date = DateTime.now
      self.save
      self.create_notification(a_user, "envió")
    end
  end
end
