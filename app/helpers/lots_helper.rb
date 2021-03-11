module LotsHelper
  def select_btn_status(relation)
    if relation.lot_stocks.present? 
      return "light"
    else
      return "primary"
    end
  end

  def lot_status_label(lot)
    if lot.vigente?; return 'success'
    elsif lot.por_vencer?; return 'warning'
    elsif lot.vencido?; return 'danger'
    end
  end
end
