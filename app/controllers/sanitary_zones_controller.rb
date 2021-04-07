class SanitaryZonesController < ApplicationController
  before_action :set_sanitary_zone, only: [:show, :edit, :update, :destroy, :delete]

  # GET /sanitary_zones
  # GET /sanitary_zones.json
  def index
    @filterrific = initialize_filterrific(
      SanitaryZone,
      params[:filterrific],
      persistence_id: false,
      available_filters: [
        :search_name,
      ],
    ) or return
    @sanitary_zones = @filterrific.find.paginate(page: params[:page], per_page: 15)
  end

  # GET /sanitary_zones/1
  # GET /sanitary_zones/1.json
  def show
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /sanitary_zones/new
  def new
    @sanitary_zone = SanitaryZone.new
  end

  # GET /sanitary_zones/1/edit
  def edit
  end

  # POST /sanitary_zones
  # POST /sanitary_zones.json
  def create
    @sanitary_zone = SanitaryZone.new(sanitary_zone_params)

    respond_to do |format|
      if @sanitary_zone.save
        flash.now[:success] = @sanitary_zone.name + " se ha creado correctamente."
        format.html { redirect_to @sanitary_zone }
        format.js
      else
        flash[:error] = "El sanitary_zone no se ha podido crear."
        format.html { render :new }
        format.js { render layout: false, content_type: 'text/javascript' }
      end
    end
  end

  # PATCH/PUT /sanitary_zones/1
  # PATCH/PUT /sanitary_zones/1.json
  def update
    respond_to do |format|
      if @sanitary_zone.update(sanitary_zone_params)
        flash.now[:success] = @sanitary_zone.name + " se ha modificado correctamente."
        format.html { redirect_to @sanitary_zone }
        format.js
      else
        flash.now[:error] = @sanitary_zone.name + " no se ha podido modificar."
        format.html { render :edit }
        format.js
      end
    end
  end

  # DELETE /sanitary_zones/1
  # DELETE /sanitary_zones/1.json
  def destroy
    sanitary_zone = @sanitary_zone.name
    @sanitary_zone.destroy
    respond_to do |format|
      flash.now[:success] = sanitary_zone.name+" se ha eliminado correctamente."
      format.js
    end
  end

  # GET /sanitary_zone/1/delete
  def delete
    respond_to do |format|
      format.js
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_sanitary_zone
    @sanitary_zone = SanitaryZone.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def sanitary_zone_params
    params.require(:sanitary_zone).permit(
      :name,
      :state_id
    )
  end
end
