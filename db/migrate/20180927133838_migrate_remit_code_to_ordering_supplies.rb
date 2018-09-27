class MigrateRemitCodeToOrderingSupplies < ActiveRecord::Migration[5.1]
  OrderingSupply.find_each do |os|
    if os.despacho?
      unless os.remit_code.present? 
        os.remit_code = os.provider_sector.name[0..3].upcase+'des'+os.id.to_s
      end
      if os.solicitud_auditoria?; os.proveedor_auditoria!;
      elsif os.solicitud_enviada?; os.proveedor_aceptado!;
      elsif os.proveedor_auditoria?; os.proveedor_en_camino!;
      elsif os.proveedor_aceptado?; os.paquete_entregado!; end
    end
    if os.recibo?
      os.remit_code = os.applicant_sector.name[0..3].upcase+'rec'+os.id.to_s
      unless os.recibo_auditoria? || os.recibo_realizado?
        os.recibo_auditoria!
      end
      os.save!
    end
  end
end
