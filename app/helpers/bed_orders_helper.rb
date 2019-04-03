module BedOrdersHelper
  def bed_order_status_label(order)
    if order.borrador?; return 'warning'
    elsif order.pendiente?; return 'info'
    elsif order.en_camino?; return 'primary'
    elsif order.entregada?; return 'success'
    elsif order.anulada?; return 'danger'
    end
  end

  def bed_order_percent_status(order)
    if order.borrador?; return 30
  elsif order.pendiente?; return 60
    elsif order.en_camino?; return 80
    elsif order.entregada?; return 100
    elsif order.anulada?; return 100
    end
  end
end