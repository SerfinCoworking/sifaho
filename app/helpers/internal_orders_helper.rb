module InternalOrdersHelper
  # Label del estado para vista.
  def internal_status_label(order)
    if order.solicitud_auditoria?; return 'warning'
    elsif order.solicitud_enviada?; return 'info'
    elsif order.proveedor_auditoria?; return 'warning'
    elsif order.provision_en_camino?; return 'primary'
    elsif order.provision_entregada?; return 'success'
    elsif order.anulada?; return 'danger'
    end
  end

  def internal_percent_status(order)
    if order.provision?
      self.internal_provision_percent_bar(order)
    elsif order.solicitud?
      self.internal_solicitud_percent_bar(order)
    end
  end

  # Porcentaje de la barra de estado de provision
  def internal_provision_percent_bar(order)
    if order.proveedor_auditoria?; return 35
    elsif order.provision_en_camino?; return 70
    elsif order.provision_entregada?; return 100
    elsif order.anulada?; return 100
    end
  end

  # Porcentaje de la barra de estado de solicitud
  def internal_solicitud_percent_bar(order)
    if order.solicitud_auditoria?; return 20
    elsif order.solicitud_enviada?; return 40
    elsif order.proveedor_auditoria?; return 60
    elsif order.provision_en_camino?; return 80
    elsif order.provision_entregada?; return 100
    elsif order.anulada?; return 100
    end
  end
end
