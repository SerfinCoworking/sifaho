module LotsHelper
  def select_btn_status(relation)
    if relation.sector_supply_lot_id.present? 
      return "light"
    else
      return "primary"
    end
  end
end
