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
      order_products.with_delivery_quantity.each(&:send_products)
      self.status = 'provision_en_camino'
      self.sent_date = DateTime.now
      self.save
      create_notification(a_user, 'envió')
    end

    # Receive order products
    def receive_order_by(a_user)
      order_products.with_delivery_quantity.each { |order_product| order_product.increment_lot_stock_to(applicant_sector) }
      update_columns(date_received: DateTime.now, status: 'provision_entregada')
      create_notification(a_user, 'recibió')
    end

    # Nullify the order
    def nullify_by(a_user)
      self.anulado!
      self.create_notification(a_user, "Anuló")
    end

    # Return the i18n model name
    def human_name
      self.class.model_name.human
    end

    # Return order type
    def custom_notification_url
      solicitud? ? 'applicant' : 'provider'
    end
  end
end
