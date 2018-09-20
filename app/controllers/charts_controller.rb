class ChartsController < ApplicationController
  def by_month_prescriptions
    render json: Prescription.group_by_month_of_year(:prescribed_date).count.map{ |k, v| [I18n.t("date.month_names")[k], v]}
  end

  def by_laboratory_lots
    render json: 
      SupplyLot.joins(:laboratory)
        .group('laboratories.name')
        .order('COUNT(laboratories.id) DESC')
        .count
        .first(10)
  end

  def by_status_current_sector_supply_lots
    render json: SectorSupplyLot.lots_for_sector(current_user.sector).group(:status).count.transform_keys { |key| key.split('_').map(&:capitalize).join(' ') }
  end
end
