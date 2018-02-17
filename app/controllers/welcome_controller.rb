class WelcomeController < ApplicationController

  def index
      _helper = ActiveSupport::NumberHelper
      _prescriptions_today = Prescription.current_day
      _prescriptions_month = Prescription.current_month
      @prescriptions = Prescription.all
      @count_prescriptions_today = _prescriptions_today.count
      @count_prescriptions_month = _prescriptions_month.count
      @count_pend_pres = _prescriptions_today.pending.count
      @count_disp_pres = _prescriptions_today.dispensed.count
      @count_pend_pres_month = _prescriptions_month.pending.count
      @count_disp_pres_month = _prescriptions_month.dispensed.count

      @percent_pendient_prescriptions = _helper.number_to_percentage((@count_pend_pres.to_f / @count_prescriptions_today  * 100), precision: 0) unless @count_pend_pres == 0
      @percent_dispensed_prescriptions = _helper.number_to_percentage((@count_disp_pres.to_f / @count_prescriptions_today * 100), precision: 0) unless @count_disp_pres == 0
      @percent_pend_pres_month = _helper.number_to_percentage((@count_pend_pres_month.to_f / @count_prescriptions_month  * 100), precision: 0) unless @count_pend_pres_month == 0
      @percent_disp_pres_month = _helper.number_to_percentage((@count_disp_pres_month.to_f / @count_prescriptions_month  * 100), precision: 0) unless @count_disp_pres_month == 0
      @last_prescriptions = Prescription.limit(5).order(date_received: :desc)

      @medications = Medication.all
      @expired_medications = Medication.expired.limit(3)
      @near_expiry_medications = Medication.near_expiry.limit(3)

      @count_total_medications = Medication.count
      @count_near_expiry_medications = Medication.near_expiry.count
      @count_expired_medications = Medication.expired.count
      @count_good_medications = Medication.in_good_state.count

      @percent_good_medications = _helper.number_to_percentage((@count_good_medications.to_f / @count_total_medications  * 100), precision: 0) unless @count_total_medications == 0
      @percent_near_expiry_medications = _helper.number_to_percentage((@count_near_expiry_medications.to_f / @count_total_medications  * 100), precision: 0) unless @count_total_medications == 0
      @percent_expired_medications = _helper.number_to_percentage((@count_expired_medications.to_f / @count_total_medications  * 100), precision: 0) unless @count_total_medications == 0
  end
end
