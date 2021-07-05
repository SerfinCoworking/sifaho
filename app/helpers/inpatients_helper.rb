module InpatientsHelper
  def bed_order_status_label(order)
    if order.borrador?; return 'warning'
    elsif order.pending?; return 'info'
    elsif order.en_camino?; return 'primary'
    elsif order.entregada?; return 'success'
    elsif order.anulada?; return 'danger'
    end
  end

  def bed_order_percent_status(order)
    if order.borrador?; return 30
    elsif order.pending?; return 60
    elsif order.en_camino?; return 80
    elsif order.entregada?; return 100
    elsif order.anulada?; return 100
    end
  end

  def bed_status_label(bed)
    if bed.disponible?
      return 'success'
    elsif bed.ocupada?
      return 'warning'
    elsif bed.inactiva?
      return 'danger'
    end
  end
end