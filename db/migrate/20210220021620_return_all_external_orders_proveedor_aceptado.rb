class ReturnAllExternalOrdersProveedorAceptado < ActiveRecord::Migration[5.2]
  def change
    ExternalOrder.proveedor_aceptado.find_each do |external_order|
      puts "External order id: "+external_order.id.to_s
      external_order.proveedor_auditoria!
      puts "Estado: "+external_order.status
    end
  end
end
