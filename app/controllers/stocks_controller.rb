class StocksController < ApplicationController
  before_action :set_stock, only: [:show, :edit, :update, :destroy, :movements]

  # GET /stocks
  # GET /stocks.json
  def index
    authorize Stock
    @filterrific = initialize_filterrific(
      Stock.to_sector(current_user.sector),
      params[:filterrific],
      select_options: {
        sorted_by: Stock.options_for_sorted_by
      },
      persistence_id: false,
    ) or return
    @areas = Area.where(id: current_user.sector.stocks.joins(product: :area).pluck("areas.id").uniq)
    if request.format.xlsx? || request.format.pdf?
      @stocks = @filterrific.find
    else
      @stocks = @filterrific.find.paginate(page: params[:page], per_page: 20)
    end
    respond_to do |format|
      format.pdf do
        send_data generate_order_report(@stocks),
          filename: 'reporte_stock_'+DateTime.now.strftime("%d/%m/%Y")+'.pdf',
          type: 'application/pdf',
          disposition: 'inline'
      end
      format.html
      format.js
      format.xlsx { headers["Content-Disposition"] = "attachment; filename=\"ReporteListadoStock_#{DateTime.now.strftime('%d-%m-%Y')}.xlsx\"" }
    end
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

  def generate_order_report(external_order)
    report = Thinreports::Report.new

    report.use_layout File.join(Rails.root, 'app', 'reports', 'stock', 'other_page.tlf'), :default => true
    report.use_layout File.join(Rails.root, 'app', 'reports', 'stock', 'first_page.tlf'), id: :cover_page
    
    # Comenzamos con la pagina principal
    report.start_new_page layout: :cover_page

    # Agregamos el encabezado
    report.page[:title] = 'Reporte de stock'
    report.page[:requested_date] = DateTime.now.strftime('%d/%m/%YY')
    report.page[:efector] = current_user.sector_name+" "+current_user.establishment_name
    report.page[:products_count].value(@stocks.count)

    # Se van agregando los productos
    @stocks.each do |stock|
      # Luego de que la primer pagina ya halla sido rellenada, agregamos la pagina defualt (no tiene header)      
      if report.page_count == 1 && report.list.overflow?
        report.start_new_page
      end
      report.list do |list|
        list.add_row do |row|
          row.values  product_code: stock.product_code,
            product_name: stock.product_name,
            unity: stock.product_unity_name,
            area: stock.product_area_name,
            lot_count: stock.lot_stocks.count,
            available_quantity: stock.quantity,
            reserved_quantity: stock.reserved_quantity,
            total_quantity: stock.total_quantity
        end
      end
    end

    # A cada pagina le agregamos el pie de pagina
    report.pages.each do |page|
      page[:page_count] = report.page_count
      page[:sector] = current_user.sector_name
      page[:establishment] = current_user.establishment_name
    end

    report.generate
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
