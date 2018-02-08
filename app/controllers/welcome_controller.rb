class WelcomeController < ApplicationController

  def index
      _helper = ActiveSupport::NumberHelper
      @prescriptions_today = Prescription.where("date_received >= :today", { today: DateTime.now.beginning_of_day.strftime('%d/%m/%Y %H:%M') })
      @count_prescriptions_today = @prescriptions_today.count
      @count_pend_pres = @prescriptions_today.where("prescription_status_id = 1").count
      @count_disp_pres = @prescriptions_today.where("prescription_status_id = 2").count

      @percent_pendient_prescriptions = _helper.number_to_percentage((@count_pend_pres.to_f / @count_prescriptions_today  * 100), precision: 0) unless @count_pend_pres == 0
      @percent_dispensed_prescriptions = _helper.number_to_percentage((@count_disp_pres.to_f / @count_prescriptions_today * 100), precision: 0) unless @count_disp_pres == 0
      @last_prescriptions = Prescription.limit(5).order(date_received: :desc)

      @count_type_medications = Medication.count
      @count_good_medications = Medication.where("expiry_date >= :date", { date: DateTime.now + 3.month }).count
      @count_near_expiry_medications = Medication.where("expiry_date <= :date", { date: DateTime.now + 3.month }).count
      @count_expired_medications = Medication.where("expiry_date <= :date", { date: DateTime.now }).count
      @count_near_expiry_medications -= @count_expired_medications  

      @percent_good_medications = _helper.number_to_percentage((@count_good_medications.to_f / @count_type_medications  * 100), precision: 0) unless @count_type_medications == 0
      @percent_near_expiry_medications = _helper.number_to_percentage((@count_near_expiry_medications.to_f / @count_type_medications  * 100), precision: 0) unless @count_type_medications == 0
      @percent_expired_medications = _helper.number_to_percentage((@count_expired_medications.to_f / @count_type_medications  * 100), precision: 0) unless @count_type_medications == 0

  end
end
