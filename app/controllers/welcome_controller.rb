class WelcomeController < ApplicationController

  def index
      _helper = ActiveSupport::NumberHelper
      @prescriptions_today = Prescription.where("date_received >= :today", { today: DateTime.now.beginning_of_day.strftime('%d/%m/%Y %H:%M') })
      @count_prescriptions_today = @prescriptions_today.count
      @count_pend_pres = @prescriptions_today.where("prescription_status_id = 1").count
      @count_disp_pres = @prescriptions_today.where("prescription_status_id = 2").count
      @percent_pendient_prescriptions = _helper.number_to_percentage((@count_pend_pres.to_f / @count_prescriptions_today  * 100), precision: 0) unless @count_pend_pres == 0
      @percent_dispensed_prescriptions = _helper.number_to_percentage((@count_disp_pres.to_f / @count_prescriptions_today * 100), precision: 0) unless @count_disp_pres == 0
  end
end
