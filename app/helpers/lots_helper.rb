module LotsHelper
  def select_btn_status(relation)
    if relation.lot_stocks.present? 
      return "light"
    else
      return "primary"
    end
  end
end
