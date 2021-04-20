class InPreProdLotStocksController < ApplicationController
  before_action :set_in_pre_prod_lot_stock, only: [:show, :edit, :update, :destroy]

  # GET /in_pre_prod_lot_stocks
  # GET /in_pre_prod_lot_stocks.json
  def index
    @in_pre_prod_lot_stocks = InPreProdLotStock.all
  end

  # GET /in_pre_prod_lot_stocks/1
  # GET /in_pre_prod_lot_stocks/1.json
  def show
  end

  # GET /in_pre_prod_lot_stocks/new
  def new
    @in_pre_prod_lot_stock = InPreProdLotStock.new
  end

  # GET /in_pre_prod_lot_stocks/1/edit
  def edit
  end

  # POST /in_pre_prod_lot_stocks
  # POST /in_pre_prod_lot_stocks.json
  def create
    @in_pre_prod_lot_stock = InPreProdLotStock.new(in_pre_prod_lot_stock_params)

    respond_to do |format|
      if @in_pre_prod_lot_stock.save
        format.html { redirect_to @in_pre_prod_lot_stock, notice: 'In pre prod lot stock was successfully created.' }
        format.json { render :show, status: :created, location: @in_pre_prod_lot_stock }
      else
        format.html { render :new }
        format.json { render json: @in_pre_prod_lot_stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /in_pre_prod_lot_stocks/1
  # PATCH/PUT /in_pre_prod_lot_stocks/1.json
  def update
    respond_to do |format|
      if @in_pre_prod_lot_stock.update(in_pre_prod_lot_stock_params)
        format.html { redirect_to @in_pre_prod_lot_stock, notice: 'In pre prod lot stock was successfully updated.' }
        format.json { render :show, status: :ok, location: @in_pre_prod_lot_stock }
      else
        format.html { render :edit }
        format.json { render json: @in_pre_prod_lot_stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /in_pre_prod_lot_stocks/1
  # DELETE /in_pre_prod_lot_stocks/1.json
  def destroy
    @in_pre_prod_lot_stock.destroy
    respond_to do |format|
      format.html { redirect_to in_pre_prod_lot_stocks_url, notice: 'In pre prod lot stock was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_in_pre_prod_lot_stock
      @in_pre_prod_lot_stock = InPreProdLotStock.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def in_pre_prod_lot_stock_params
      params.require(:in_pre_prod_lot_stock).permit(:inpatient_prescription_product_id, :lot_stock_id, :dispensed_by_id, :quantity)
    end
end
