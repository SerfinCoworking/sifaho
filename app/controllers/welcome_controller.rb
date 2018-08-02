class WelcomeController < ApplicationController

  def index
      _helper = ActiveSupport::NumberHelper
      _prescriptions_today = Prescription.current_day
      _prescriptions_month = Prescription.current_month
      @prescriptions = Prescription.all
      @count_prescriptions_today = _prescriptions_today.count
      @count_prescriptions_month = _prescriptions_month.count
      @count_pend_pres = _prescriptions_today.pendiente.count
      @count_disp_pres = _prescriptions_today.dispensada.count
      @count_pend_pres_month = _prescriptions_month.pendiente.count
      @count_disp_pres_month = _prescriptions_month.dispensada.count

      @percent_pendient_prescriptions = _helper.number_to_percentage((@count_pend_pres.to_f / @count_prescriptions_today  * 100), precision: 0) unless @count_pend_pres == 0
      @percent_dispensed_prescriptions = _helper.number_to_percentage((@count_disp_pres.to_f / @count_prescriptions_today * 100), precision: 0) unless @count_disp_pres == 0
      @percent_pend_pres_month = _helper.number_to_percentage((@count_pend_pres_month.to_f / @count_prescriptions_month  * 100), precision: 0) unless @count_pend_pres_month == 0
      @percent_disp_pres_month = _helper.number_to_percentage((@count_disp_pres_month.to_f / @count_prescriptions_month  * 100), precision: 0) unless @count_disp_pres_month == 0
      @last_prescriptions = Prescription.limit(5).order(date_received: :desc)

      @supply_lots = SupplyLot.all
      @expired_supply_lots = SupplyLot.vencido.limit(3)
      @near_expiry_supply_lots = SupplyLot.por_vencer.limit(3)

      @count_total_supply_lots = SupplyLot.count
      @count_near_expiry_supply_lots = SupplyLot.por_vencer.count
      @count_expired_supply_lots = SupplyLot.vencido.count
      @count_good_supply_lots = SupplyLot.vigente.count

      @percent_good_supply_lots = _helper.number_to_percentage((@count_good_supply_lots.to_f / @count_total_supply_lots  * 100), precision: 0) unless @count_total_supply_lots == 0
      @percent_near_expiry_supply_lots = _helper.number_to_percentage((@count_near_expiry_supply_lots.to_f / @count_total_supply_lots  * 100), precision: 0) unless @count_total_supply_lots == 0
      @percent_expired_supply_lots = _helper.number_to_percentage((@count_expired_supply_lots.to_f / @count_total_supply_lots  * 100), precision: 0) unless @count_total_supply_lots == 0
  end
end
