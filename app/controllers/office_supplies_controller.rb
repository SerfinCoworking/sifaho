class OfficeSuppliesController < ApplicationController
  before_action :set_office_supply, only: [:show, :edit, :update, :destroy]

  # GET /office_supplies
  # GET /office_supplies.json
  def index
    authorize OfficeSupply
    @filterrific = initialize_filterrific(
      OfficeSupply.sector(current_user.sector),
      params[:filterrific],
      select_options: {
        with_status: OfficeSupply.options_for_status
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'creado_desc'},
      available_filters: [
        :search_supply,
        :search_description,
        :with_status,
        :sorted_by
      ],
    ) or return
    @office_supplies = @filterrific.find.page(params[:page]).per_page(8)
  end

  # GET /office_supplies/1
  # GET /office_supplies/1.json
  def show
    authorize @office_supply
  end

  # GET /office_supplies/new
  def new
    authorize OfficeSupply
    @office_supply = OfficeSupply.new
  end

  # GET /office_supplies/1/edit
  def edit
    authorize @office_supply
  end

  # POST /office_supplies
  # POST /office_supplies.json
  def create
    @office_supply = OfficeSupply.new(office_supply_params)
    authorize @office_supply

    respond_to do |format|
      if @office_supply.save
        format.html { redirect_to @office_supply, notice: 'Office supply was successfully created.' }
        format.json { render :show, status: :created, location: @office_supply }
      else
        format.html { render :new }
        format.json { render json: @office_supply.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /office_supplies/1
  # PATCH/PUT /office_supplies/1.json
  def update
    authorize @office_supply
    respond_to do |format|
      if @office_supply.update(office_supply_params)
        format.html { redirect_to @office_supply, notice: 'Office supply was successfully updated.' }
        format.json { render :show, status: :ok, location: @office_supply }
      else
        format.html { render :edit }
        format.json { render json: @office_supply.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /office_supplies/1
  # DELETE /office_supplies/1.json
  def destroy
    authorize @office_supply 
    @office_supply.destroy
    respond_to do |format|
      format.html { redirect_to office_supplies_url, notice: 'Office supply was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_office_supply
      @office_supply = OfficeSupply.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def office_supply_params
      params.require(:office_supply).permit(:name, :description, :quantity, :status, :sector_id, :remit_code)
    end
end
