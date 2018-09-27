module OrderingSuppliesHelper
  def ordering_status_label(order)
    # Label del estado para vista.
    if order.solicitud_auditoria?; return 'default'
    elsif order.solicitud_enviada?; return 'info'
    elsif order.proveedor_auditoria?; return 'warning'
    elsif order.proveedor_aceptado?; return 'primary'
    elsif order.proveedor_en_camino?; return 'primary'
    elsif order.paquete_entregado?; return 'success'
    elsif order.recibo_auditoria?; return 'warning'
    elsif order.recibo_realizado?; return 'success' 
    elsif order.anulado?; return 'danger'
    end
  end

  def ordering_percent_status(order)
    if order.despacho?
      self.ordering_despacho_percent_bar(order)
    elsif order.solicitud?
      self.ordering_solicitud_percent_bar(order)
    elsif order.recibo?
      self.ordering_recibo_percent_bar(order)
    end
  end

  # Porcentaje de la barra de estado de pedido tipo despacho
  def ordering_despacho_percent_bar(order)
    if order.proveedor_auditoria?; return 5
    elsif order.proveedor_aceptado?; return 34
    elsif order.proveedor_en_camino?; return 71
    elsif order.paquete_entregado?; return 100
    elsif order.anulado?; return 100
    end
  end

  # Porcentaje de la barra de estado de pedido tipo solicitud
  def ordering_solicitud_percent_bar(order)
    if order.solicitud_auditoria?; return 5
    elsif order.solicitud_enviada?; return 20 
    elsif order.proveedor_auditoria?; return 30
    elsif order.proveedor_aceptado?; return 50
    elsif order.proveedor_en_camino?; return 71
    elsif order.paquete_entregado?; return 100
    elsif order.anulado?; return 100
    end
  end

  # Porcentaje de la barra de estado de pedido tipo recibo
  def ordering_recibo_percent_bar(order)
    if order.recibo_auditoria?; return 50
    elsif order.recibo_realizado?; return 100
    end
  end
end
