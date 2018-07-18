class SupplyLotsController < ApplicationController
  before_action :set_supply_lot, only: [:show, :edit, :update, :destroy]

  # GET /supply_lots
  # GET /supply_lots.json
  def index
    @supply_lots = SupplyLot.all
  end

  # GET /supply_lots/1
  # GET /supply_lots/1.json
  def show
  end

  # GET /supply_lots/new
  def new
    @supply_lot = SupplyLot.new
  end

  # GET /supply_lots/1/edit
  def edit
  end

  # POST /supply_lots
  # POST /supply_lots.json
  def create
    @supply_lot = SupplyLot.new(supply_lot_params)

    respond_to do |format|
      if @supply_lot.save
        format.html { redirect_to @supply_lot, notice: 'Supply lot was successfully created.' }
        format.json { render :show, status: :created, location: @supply_lot }
      else
        format.html { render :new }
        format.json { render json: @supply_lot.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /supply_lots/1
  # PATCH/PUT /supply_lots/1.json
  def update
    respond_to do |format|
      if @supply_lot.update(supply_lot_params)
        format.html { redirect_to @supply_lot, notice: 'Supply lot was successfully updated.' }
        format.json { render :show, status: :ok, location: @supply_lot }
      else
        format.html { render :edit }
        format.json { render json: @supply_lot.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /supply_lots/1
  # DELETE /supply_lots/1.json
  def destroy
    @supply_lot.destroy
    respond_to do |format|
      format.html { redirect_to supply_lots_url, notice: 'Supply lot was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_supply_lot
      @supply_lot = SupplyLot.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def supply_lot_params
      params.require(:supply_lot).permit(:code, :expiry_date, :date_received, :quantity, :initial_quantity, :status)
    end
end
