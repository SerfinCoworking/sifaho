class WelcomeController < ApplicationController

  def index
    if current_user.sector.present?
      _helper = ActiveSupport::NumberHelper
      _prescriptions_today = Prescription.with_establishment(current_user.establishment).current_day
      _prescriptions_month = Prescription.with_establishment(current_user.establishment).current_month
      
      # Ultimos 13 días más el día actual
      @outpatient_prescriptions_query_by_days = OutpatientPrescription.with_establishment(current_user.establishment).group_by_day(:date_prescribed, range: 13.days.ago..DateTime.now).count
      @outpatient_prescriptions_by_days = @outpatient_prescriptions_query_by_days.values
      @chronic_prescriptions_query_by_days = ChronicPrescription.with_establishment(current_user.establishment).group_by_day(:date_prescribed, range: 13.days.ago..DateTime.now, format: "%B %d").count
      @chronic_prescriptions_by_days = @chronic_prescriptions_query_by_days.values
      @chronic_prescriptions_days = @chronic_prescriptions_query_by_days.keys
      
      # Ultimos 11 meses más el mes actual
      @outpatient_prescriptions_query = OutpatientPrescription.with_establishment(current_user.establishment).group_by_month(:date_prescribed, range: 11.months.ago..DateTime.now).count
      @outpatient_prescriptions = @outpatient_prescriptions_query.values
      @chronic_prescriptions_query = ChronicPrescription.with_establishment(current_user.establishment).group_by_month(:date_prescribed, range: 11.months.ago..DateTime.now, format: "%B %Y").count
      @chronic_prescriptions = @chronic_prescriptions_query.values
      @chronic_prescriptions_months = @chronic_prescriptions_query.keys
      
      @last_outpatient_prescriptions = OutpatientPrescription.with_establishment(current_user.establishment).order(created_at: :desc).limit(5)
      @last_chronic_prescriptions = ChronicPrescription.with_establishment(current_user.establishment).order(created_at: :desc).limit(5)

      # @prescriptions = (@chronic_prescriptions + @outpatient_prescriptions)
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
      # @last_prescriptions = @prescriptions.sort_by(&:date_prescribed).last(5)
      
      @lot_stocks = LotStock.joins("INNER JOIN stocks ON lot_stocks.stock_id = stocks.id").where("stocks.sector_id = #{current_user.sector.id} AND stocks.quantity > 0")
      @expired_lot_stocks = @lot_stocks.with_status(2).limit(3)
      @near_expiry_lots = @lot_stocks.with_status(1).limit(3)

      @count_total_lots = @lot_stocks.count
      @count_expired_lots = @expired_lot_stocks.count
      @count_near_expiry_lots = @near_expiry_lots.count
      @count_good_lots = @lot_stocks.with_status(0).count

      # Tomamos los estados de los lotes
      @lots = LotStock.joins(:stock).joins(:sector).joins(:lot).where("sectors.id = ?", current_user.sector).where.not("lots.status = ?", 4).group("lots.status").count
      status_colors = {0 => "#40c95e", 1 => "#f1ae45", 2 => "#d36262" }
      # formateamos los colores segun el tipo de estado
      @colors = []
      @lots.each do |status, _|
        @colors << status_colors[status]
      end

      @percent_good_supply_lots = _helper.number_to_percentage((@count_good_lots.to_f / @count_total_lots  * 100), precision: 0) unless @count_total_lots == 0
      @percent_near_expiry_lots = _helper.number_to_percentage((@count_near_expiry_lots.to_f / @count_total_lots  * 100), precision: 0) unless @count_total_lots == 0
      @percent_expired_lots = _helper.number_to_percentage((@count_expired_lots.to_f / @count_total_lots  * 100), precision: 0) unless @count_total_lots == 0
    
      @external_orders_origin = ExternalOrder.my_orders(current_user.sector)
      @external_orders_destination = ExternalOrder.other_orders(current_user.sector)

    else
      @permission_request = PermissionRequest.new
    end
  end
end
