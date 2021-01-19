module PrescriptionsHelper
  # Label del estado para vista.
  def outpatient_prescription_status_label(order)
    if order.pendiente?; return 'secondary'
    elsif order.dispensada?; return 'success'
    elsif order.vencida?; return 'danger'
    end
  end

  def chronic_prescription_status_label(order)
    if order.pendiente?; return 'secondary'
    elsif order.dispensada?; return 'success'
    elsif order.dispensada_parcial?; return 'primary'
    elsif order.vencida?; return 'danger'
    end
  end
end
