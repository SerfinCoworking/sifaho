class SectorsController < ApplicationController
  def with_establishment_id
    @sectors = Sector.order(:sector_name).with_establishment_id(params[:term])
    render json: @sectors.map{ |sector| { label: sector.sector_name, id: sector.id } }
  end
end
