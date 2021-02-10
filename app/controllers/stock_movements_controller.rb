class StockMovementsController < ApplicationController

  # GET /stocks
  # GET /stocks.json
  def index
    authorize StockMovement
    @stock = Stock.find(params[:id])
    @filterrific = initialize_filterrific(
      StockMovement.to_stock_id(@stock.id),
      params[:filterrific],
      select_options: {
        sorted_by: StockMovement.options_for_sorted_by
      },
      persistence_id: false,
    ) or return

    if request.format.xlsx?
      @stock_movements = @filterrific.find
    else
      @stock_movements = @filterrific.find.page(params[:page]).per_page(20)
    end
    
    respond_to do |format|
      format.html
      format.js
      format.xlsx { headers["Content-Disposition"] = "attachment; filename=\"MovStock_COD#{@stock.product.code}_#{DateTime.now.strftime('%d-%m-%Y')}.xlsx\"" }
    end
  end

  def movements
    authorize @stock
    @movements = @stock.movements.sort_by{|e| e[:created_at]}.reverse.paginate(:page => params[:page], :per_page => 15)
  end

  # GET /stocks/1
  # GET /stocks/1.json
  def show
  end

  # GET /stocks/new
  def new
    @stock = Stock.new
  end

  # GET /stocks/1/edit
  def edit
  end

  # POST /stocks
  # POST /stocks.json
  def create
    @stock = Stock.new(stock_params)

    respond_to do |format|
      if @stock.save
        format.html { redirect_to @stock, notice: 'Stock was successfully created.' }
        format.json { render :show, status: :created, location: @stock }
      else
        format.html { render :new }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stocks/1
  # PATCH/PUT /stocks/1.json
  def update
    respond_to do |format|
      if @stock.update(stock_params)
        format.html { redirect_to @stock, notice: 'Stock was successfully updated.' }
        format.json { render :show, status: :ok, location: @stock }
      else
        format.html { render :edit }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stocks/1
  # DELETE /stocks/1.json
  def destroy
    @stock.destroy
    respond_to do |format|
      format.html { redirect_to stocks_url, notice: 'Stock was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def find_lots   
    # Buscamos los lot_stocks que pertenezcan al sector del usuario y ademas tengan stock
    @lot_stocks = LotStock.joins(:stock)
      .joins(:product)
      .where("stocks.sector_id = ?", current_user.sector.id)
      .where("products.code like ?", params[:product_code])
      .where("lot_stocks.quantity > ?", 0)

    respond_to do |format|
      format.json { render json: @lot_stocks.to_json(
        :include => { 
          :lot => {
            :only => [:code, :expiry_date, :status], 
            :include => {
              :laboratory => {:only => [:name]}
            } 
          }
        }), status: :ok }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stock
      @stock = Stock.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def stock_params
      params.require(:stock).permit(:supply_id, :sector_id, :quantity)
    end
end
