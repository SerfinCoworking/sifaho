module OrdersHelper
  def highlight_row(an_id)
    if @highlight_row.present? && @highlight_row == an_id 
      return 'table-info'
    end
  end

  def highlight_applicant_row_bg(order)
    'table-info' if order.present? && order.provision_en_camino?
  end
  
  def highlight_provider_row_bg(order)
    'table-info' if order.present? && order.solicitud_enviada?
  end
end