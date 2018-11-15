module PrescriptionsHelper
  # Label del estado para vista.
  def prescription_status_label(order)
    if order.pendiente?; return 'default'
    elsif order.dispensada?; return 'success'
    elsif order.vencida?; return 'danger'
    end
  end
end
