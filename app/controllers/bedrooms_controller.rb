class BedroomsController < ApplicationController
  before_action :set_bedroom, only: [:show, :edit, :update, :destroy]

  # GET /beds
  # GET /beds.json
  def index
    authorize Bedroom
    @filterrific = initialize_filterrific(
      Bedroom.establishment(current_user.sector.establishment),
      params[:filterrific],
      select_options: {
        sorted_by: Bedroom.options_for_sorted_by
      },
      persistence_id: false,
    ) or return
    @bedrooms = @filterrific.find.paginate(page: params[:page], per_page: 15)
  end
    
  # GET /beds/1
  # GET /beds/1.json
  def show
    authorize @bedroom
  end

  # GET /beds/new
  def new
    authorize Bedroom
    @bedroom = Bedroom.new
    @sectors = Sector.select(:id, :name)
                     .with_establishment_id(current_user.sector.establishment_id)
                     .provide_hospitalization
  end

  # GET /beds/1/edit
  def edit
    authorize @bedroom
    @sectors = Sector.select(:id, :name)
                     .with_establishment_id(current_user.sector.establishment_id)
                     .provide_hospitalization
  end

  # POST /beds
  # POST /beds.json
  def create
    @bedroom = Bedroom.new(bedroom_params)
    authorize @bedroom

    respond_to do |format|
      if @bedroom.save
        format.html { redirect_to @bedroom, notice: 'La habitación se ha creado correctamente.' }
      else
        @sectors = Sector
          .select(:id, :name)
          .with_establishment_id(current_user.sector.establishment_id)
          .where.not(id: current_user.sector_id)
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /beds/1
  # PATCH/PUT /beds/1.json
  def update
    authorize @bedroom
    respond_to do |format|
      if @bedroom.update(bedroom_params)
        format.html { redirect_to @bedroom, notice: 'La habitación se ha modificado correctamente.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /beds/1
  # DELETE /beds/1.json
  def destroy
    authorize @bedroom
    @bedroom.destroy
    respond_to do |format|
      format.html { redirect_to beds_url, notice: 'La habitación se ha enviado a la papelera correctamente.' }
      format.json { head :no_content }
    end
  end

  def new_bed
    authorize Bed
    @bedroom = Bed.new
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bedroom
      @bedroom = Bedroom.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bedroom_params
      params.require(:bedroom).permit(:name, :location_sector_id)
    end
end
