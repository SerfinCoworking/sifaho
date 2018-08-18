class ChartsController < ApplicationController
  def by_month_prescriptions
    render json: Prescription.group_by_month_of_year(:prescribed_date).count.map{ |k, v| [I18n.t("date.month_names")[k], v]}
  end

  def by_laboratory_lots
    render json: SupplyLot.joins(:laboratory).group('laboratories.name').count
  end
end
