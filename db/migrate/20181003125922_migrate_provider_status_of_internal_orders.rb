class MigrateProviderStatusOfInternalOrders < ActiveRecord::Migration[5.1]
  InternalOrder.find_each do |io|
    if io.provider_nuevo?
      io.solicitud_nueva!
    elsif io.provider_auditoria?
      io.proveedor_auditoria!
    elsif io.provider_en_camino?
      io.paquete_en_camino!
    elsif io.provider_entregado?
      io.provision_entregada!
    end
  end
end
