module OrdersHelper
  def highlight_row(an_id)
    if @highlight_row.present? && @highlight_row == an_id 
      return 'table-info'
    end
  end
end