class SectorsController < ApplicationController
  before_action :set_sector, only: [:show, :new, :edit, :create, :update, :destroy, :delete]

  # GET /establishments
  # GET /establishments.json
  def index
    @filterrific = initialize_filterrific(
      Sector,
      params[:filterrific],
      persistence_id: false,
      available_filters: [
        :search_name,
      ],
    ) or return
    @sectors = @filterrific.find.page(params[:page]).per_page(15)
  end

  # GET /establishments/1
  # GET /establishments/1.json
  def show
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /establishments/new
  def new
    # @sector = Sector.new
  end

  # GET /establishments/1/edit
  def edit
  end

  # POST /establishments
  # POST /establishments.json
  def create
    @sector = Sector.new(sector_params)

    respond_to do |format|
      if @sector.save!
        flash.now[:success] = @sector.name + " se ha creado correctamente."
        format.html { redirect_to @sector }
        format.js
      else
        flash[:error] = "El sector no se ha podido crear."
        format.html { render :new }
        format.js { render layout: false, content_type: 'text/javascript' }
      end
    end
  end

  # PATCH/PUT /establishments/1
  # PATCH/PUT /establishments/1.json
  def update
    respond_to do |format|
      if @sector.update(sector_params)
        flash.now[:success] = @sector.name + " se ha modificado correctamente."
        format.html { redirect_to @sector }
        format.js
      else
        flash.now[:error] = @sector.name + " no se ha podido modificar."
        format.html { render :edit }
        format.js
      end
    end
  end

  # DELETE /establishments/1
  # DELETE /establishments/1.json
  def destroy
    sector = @sector.name
    @sector.destroy
    respond_to do |format|
      flash.now[:success] = "El sector "+sector+" se ha eliminado correctamente."
      format.js
    end
  end

  # GET /establishment/1/delete
  def delete
    respond_to do |format|
      format.js
    end
  end

  def with_establishment_id
    @sectors = Sector.order(:name).with_establishment_id(params[:term])
    render json: @sectors.map{ |sector| { label: sector.name, id: sector.id } }
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_sector
    @sector = params[:id].present? ? Sector.find(params[:id]) : Sector.new
    @establishments = Establishment.all
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def sector_params
    params.require(:sector).permit(
      :name,
      :establishment_id,
      :description
    )
  end
end
