class BedroomsController < ApplicationController
  before_action :set_bedroom, only: [:show, :edit, :update, :destroy]

  # GET /beds
  # GET /beds.json
  def index
    authorize BedRoom
    @filterrific = initialize_filterrific(
      Bed.establishment(current_user.sector.establishment),
      params[:filterrific],
      select_options: {
        with_status: Bed.options_for_status,
        sorted_by: Bed.options_for_sorted_by
      },
      persistence_id: false,
    ) or return
    @bedrooms = @filterrific.find.page(params[:page]).per_page(15)
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
    @sectors = Sector
      .select(:id, :name)
      .with_establishment_id(current_user.sector.establishment_id)
      .where.not(id: current_user.sector_id)
  end

  # GET /beds/1/edit
  def edit
    authorize @bedroom
  end

  # POST /beds
  # POST /beds.json
  def create
    @bedroom = Bed.new(bed_params)
    @bedroom.establishment_id = current_user.sectoor.establishment_id
    authorize @bedroom

    respond_to do |format|
      if @bedroom.save
        @bedroom.create_notification(current_user, "creó")
        format.html { redirect_to @bedroom, notice: 'El pedido de internación se ha creado correctamente.' }
        format.json { render :show, status: :created, location: @bedroom }
      else
        @bedrooms = Bed.joins(:bedroom).pluck(:id, :name, "bedrooms.name")
        format.html { render :new }
        format.json { render json: @bedroom.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /beds/1
  # PATCH/PUT /beds/1.json
  def update
    authorize @bedroom
    respond_to do |format|
      if @bedroom.update(bed_params)
        format.html { redirect_to @bedroom, notice: 'El pedido de internación se ha modificado correctamente.' }
        format.json { render :show, status: :ok, location: @bedroom }
      else
        format.html { render :edit }
        format.json { render json: @bedroom.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /beds/1
  # DELETE /beds/1.json
  def destroy
    authorize @bedroom
    @bedroom.destroy
    respond_to do |format|
      format.html { redirect_to beds_url, notice: 'El pedido de internación se ha enviado a la papelera correctamente.' }
      format.json { head :no_content }
    end
  end

  def new_bed
    authorize Bed
    @bedroom = Bed.new
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bed
      @bedroom = Bed.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bed_params
      params.require(:bed).permit(:name, :sector)
    end
end
