module Order
  extend ActiveSupport::Concern

  included do 

    # Cambia estado a "en camino" y descuenta la cantidad a los lotes de insumos
    def send_order_by(a_user)
      self.order_products.with_delivery_quantity.each(&:send_products)
      self.status = 'provision_en_camino'
      self.sent_date = DateTime.now
      self.sent_by_id = a_user.id
      self.save
      self.create_notification(a_user, "envió")
    end
  end
end
