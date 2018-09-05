class SectorsController < ApplicationController
  def with_establishment_id
    @sectors = Sector.order(:name).with_establishment_id(params[:term])
    render json: @sectors.map{ |sector| { label: sector.name, id: sector.id } }
  end
end
