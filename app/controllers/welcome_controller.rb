class WelcomeController < ApplicationController

  def index
    if current_user.sector.present?
      _helper = ActiveSupport::NumberHelper
      _prescriptions_today = Prescription.with_establishment(current_user.establishment).current_day
      _prescriptions_month = Prescription.with_establishment(current_user.establishment).current_month
      @prescriptions = Prescription.with_establishment(current_user.establishment)
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
      @last_prescriptions = @prescriptions.order(date_received: :desc).limit(5)

      @supply_lots = SectorSupplyLot.lots_for_sector(current_user.sector)
      @expired_supply_lots = @supply_lots.with_status(2).limit(3)
      @near_expiry_supply_lots = @supply_lots.with_status(1).limit(3)

      @count_total_supply_lots = @supply_lots.count
      @count_near_expiry_supply_lots = @supply_lots.with_status(1).count
      @count_expired_supply_lots = @supply_lots.with_status(2).count
      @count_good_supply_lots = @supply_lots.with_status(0).count

      @percent_good_supply_lots = _helper.number_to_percentage((@count_good_supply_lots.to_f / @count_total_supply_lots  * 100), precision: 0) unless @count_total_supply_lots == 0
      @percent_near_expiry_supply_lots = _helper.number_to_percentage((@count_near_expiry_supply_lots.to_f / @count_total_supply_lots  * 100), precision: 0) unless @count_total_supply_lots == 0
      @percent_expired_supply_lots = _helper.number_to_percentage((@count_expired_supply_lots.to_f / @count_total_supply_lots  * 100), precision: 0) unless @count_total_supply_lots == 0
    else
      @permission_request = PermissionRequest.new
    end
  end
end
