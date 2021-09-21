class SetDeliverQuantityZero < ActiveRecord::Migration[5.2]
  def change
    # Iterate through all 'proveedor auditoria' external and internal order and destroy the ord_prod_lot_stock relationships
    ExternalOrder.proveedor_auditoria.find_each do |order|
      order.order_products.find_each do |order_product|
        order_product.delivery_quantity = 0
        order_product.save(validate: false)
      end
    end

    InternalOrder.proveedor_auditoria.find_each do |order|
      order.order_products.find_each do |order_product|
        order_product.delivery_quantity = 0
        order_product.save(validate: false)
      end
    end
  end
end
