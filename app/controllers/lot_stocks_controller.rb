class LotStocksController < ApplicationController

  before_action :set_lot_stock, only: [:new_archive, :create_archive, :show]
  before_action :set_lot_archive, only: [:return_archive_modal, :show_lot_archive, :return_archive]
  # GET /stocks
  # GET /stocks.json
  def index
    authorize LotStock
    @filterrific = initialize_filterrific(
      LotStock.joins(:stock).where("stocks.sector_id = #{current_user.sector.id}"),
      params[:filterrific],
      select_options: {
        sorted_by: LotStock.options_for_sort,
        search_by_status: LotStock.options_for_status,
        search_by_quantity: LotStock.options_for_quantity
      },
      persistence_id: false,
    ) or return
    @stocks = ''

    @lot_stocks = request.format.xlsx? ? @filterrific.find : @filterrific.find.paginate(page: params[:page], per_page: 20)

    respond_to do |format|
      format.html
      format.js
      format.xlsx { headers['Content-Disposition'] = "attachment; filename=\"Lotes_#{DateTime.now.strftime('%d-%m-%Y')}.xlsx\"" }
    end
  end

  # GET /stocks
  # GET /stocks.json
  def lot_stocks_by_stock
    authorize LotStock
    @stock = Stock.find(params[:stock_id])
    @filterrific = initialize_filterrific(
      LotStock.by_stock(@stock.id),
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
    @reserved_lots = @lot_stock.movements_with_reserved_quantity
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
      format.html { redirect_to stock_show_lot_stocks_url(@lot_archive.lot_stock.stock, @lot_archive.lot_stock), notice: 'El archivo se retorno correctamente.' }
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
end
