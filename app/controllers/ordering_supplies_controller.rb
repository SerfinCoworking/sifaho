class OrderingSuppliesController < ApplicationController
  before_action :set_ordering_supply, only: [:show, :edit, :update, :destroy]

  # GET /ordering_supplies
  # GET /ordering_supplies.json
  def index
    def index
      authorize OrderingSupply
      @filterrific = initialize_filterrific(
        OrderingSupply,
        params[:filterrific],
        select_options: {
          sorted_by: OrderingSupply.options_for_sorted_by
        },
        persistence_id: false,
        default_filter_params: {sorted_by: 'created_at_desc'},
        available_filters: [
          :search_professional_and_patient,
          :search_supply_code,
          :search_supply_name,
          :sorted_by,
          :date_prescribed_since,
          :date_dispensed_since
        ],
      ) or return
      @ordering_supplies = @filterrific.find.page(params[:page]).per_page(8)
    end
  end

  # GET /ordering_supplies/1
  # GET /ordering_supplies/1.json
  def show
    authorize @ordering_supply
    respond_to do |format|
      format.js
    ends
  end

  # GET /ordering_supplies/new
  def new
    authorize OrderingSupply
    @ordering_supply = OrderingSupply.new
    @ordering_supply.quantity_ord_supply_lots.build
  end

  # GET /ordering_supplies/1/edit
  def edit
    authorize @ordering_supply
    @ordering_supply.quantity_ord_supply_lots || @ordering_supply.quantity_ord_supply_lots.build
  end

  # POST /ordering_supplies
  # POST /ordering_supplies.json
  def create
    @ordering_supply = OrderingSupply.new(ordering_supply_params)

    respond_to do |format|
      if @ordering_supply.save
        format.html { redirect_to @ordering_supply, notice: 'Ordering supply was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /ordering_supplies/1
  # PATCH/PUT /ordering_supplies/1.json
  def update
    respond_to do |format|
      if @ordering_supply.update(ordering_supply_params)
        format.html { redirect_to @ordering_supply, notice: 'Ordering supply was successfully updated.' }
        format.json { render :show, status: :ok, location: @ordering_supply }
      else
        format.html { render :edit }
        format.json { render json: @ordering_supply.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ordering_supplies/1
  # DELETE /ordering_supplies/1.json
  def destroy
    @ordering_supply.destroy
    respond_to do |format|
      format.html { redirect_to ordering_supplies_url, notice: 'Ordering supply was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ordering_supply
      @ordering_supply = OrderingSupply.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ordering_supply_params
      params.require(:ordering_supply).permit(:sector_id, :observation, :date_received, :status)
    end
end
