class EstablishmentsController < ApplicationController
  def search_by_name
    @establishments = Establishment.order(:name).search_name(params[:term]).limit(10).where_not_id(current_user.sector.establishment_id)
    render json: @establishments.map{ |est| { label: est.name, id: est.id } }
  end
end
