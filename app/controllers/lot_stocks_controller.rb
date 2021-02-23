class LotStocksController < ApplicationController

  before_action :set_lot_stock, only: [:new_archive, :create_archive, :show]
  before_action :set_lot_archive, only: [:return_archive_modal, :show_lot_archive, :return_archive]
  # GET /stocks
  # GET /stocks.json
  def index
    authorize LotStock
    @stock = Stock.find(params[:id])
    @filterrific = initialize_filterrific(
      LotStock.by_stock(params[:id]),
      params[:filterrific],
      select_options: {
        sorted_by: Stock.options_for_sorted_by_lots
      },
      persistence_id: false,
    ) or return

    if request.format.xlsx?
      @lot_stocks = @filterrific.find
    else
      @lot_stocks = @filterrific.find.page(params[:page]).per_page(20)
    end
    
    respond_to do |format|
      format.html
      format.js
      # format.xlsx { headers["Content-Disposition"] = "attachment; filename=\"MovStock_COD#{@stock.product.code}_#{DateTime.now.strftime('%d-%m-%Y')}.xlsx\"" }
    end
  end

  def movements
    authorize @stock
    @movements = @stock.movements.sort_by{|e| e[:created_at]}.reverse.paginate(:page => params[:page], :per_page => 15)
  end

  # GET /stocks/1
  # GET /stocks/1.json
  def show
    authorize @lot_stock
    @reserved_lots = @lot_stock.ext_ord_prod_lot_stocks
      .where("external_orders.status = 3").joins(:order, :external_order_product).order("external_orders.updated_at DESC")
  end
  
  # GET /stocks/1
  # GET /stocks/1.json
  def show_lot_archive
    authorize @lot_archive
  end
  
  def new_archive
    authorize @lot_stock
    @lot_archive = LotArchive.new
    respond_to do |format|
      format.js
    end
  end
  
  def create_archive
    authorize @lot_stock    
    @lot_archive = LotArchive.new(lot_archive_params)
    @lot_archive.user_id = current_user.id
    
    respond_to do |format|
      if @lot_archive.save
        format.html { redirect_to show_lot_stocks_path(id: @lot_stock.stock_id,lot_stock_id: @lot_stock.id), notice: 'Lote archivado correctamente.' }
      else
        format.js { render :new_archive }
      end
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

  def return_archive_modal
    authorize @lot_archive
    respond_to do |format|
      format.js
    end
  end
  
  def return_archive
    authorize @lot_archive
    @lot_archive.return_by(current_user)
    respond_to do |format|
      format.html { redirect_to show_lot_stocks_url(@lot_archive.lot_stock.stock, @lot_archive.lot_stock), notice: 'El archivo se retorno correctamente.' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lot_stock
      @lot_stock = LotStock.find(params[:lot_stock_id])
    end
    
    def set_lot_archive
      @lot_archive = LotArchive.find(params[:id])
    end

    def lot_archive_params
      params.require(:lot_archive).permit([
        :lot_stock_id,
        :quantity,
        :observation
      ])
    end
end
