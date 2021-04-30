class Reports::StockQuantityReportsController < ApplicationController
  before_action :set_stock_quantity_report, only: [:show]

  def show
    authorize @stock_quantity_report

      @stocks = Stock
        .with_area_ids(@stock_quantity_report.areas.ids)
        .reorder("products.name ASC")
        .joins(:product)
        .uniq { |p| p.product_id }
      
    respond_to do |format|
      format.html
      format.pdf do
        send_data generate_report(@stocks, @params),
          filename: 'reporte_stock_por_rubro.pdf',
          type: 'application/pdf',
          disposition: 'inline'
      end
      format.xlsx { headers["Content-Disposition"] = "attachment; filename=\"ReporteStockPorRubro_#{DateTime.now.strftime('%d-%m-%Y')}.xlsx\"" }
    end
  end

  def new
    authorize StockQuantityReport
    @stock_quantity_report = StockQuantityReport.new
    @areas = Area.where(id: current_user.sector.stocks.joins(product: :area).pluck("areas.id").uniq)
    @last_reports = StockQuantityReport.where(sector_id: current_user.sector_id).limit(10).order(created_at: :desc)
  end

  def create
    @stock_quantity_report = StockQuantityReport.new(stock_quantity_report_params)
    @stock_quantity_report.created_by = current_user
    @stock_quantity_report.sector = current_user.sector
    authorize @stock_quantity_report

    respond_to do |format|
      if @stock_quantity_report.save
        format.html { redirect_to reports_stock_quantity_report_path(@stock_quantity_report), notice: 'El reporte se ha creado correctamente.' }
      else
        @last_reports = StockQuantityReport.limit(10)
        format.html { render :new }
      end
    end
  end
  
  private
  
    def set_stock_quantity_report
      @stock_quantity_report = StockQuantityReport.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def stock_quantity_report_params
      params.require(:stock_quantity_report).permit(area_ids: [])
    end

    def generate_report(stocks, params)
      report = Thinreports::Report.new layout: File.join(Rails.root, 'app', 'reports', 'stock', 'quantity_first_page.tlf')
      
      # report.use_layout File.join(Rails.root, 'app', 'reports', 'stock', 'quantity_first_page.tlf'), :default => true
      report.use_layout File.join(Rails.root, 'app', 'reports', 'stock', 'quantity_second_page.tlf'), id: :other_page
      
      # Comenzamos con la pagina principal
      report.start_new_page

      report.page[:efector] = @stock_quantity_report.sector.sector_and_establishment
      report.page[:areas_count] = @stock_quantity_report.areas.count > 5 ? @stock_quantity_report.areas.count.to_s+' rubros' : @stock_quantity_report.areas.map(&:name).join(", ")
      report.page[:products_count] = stocks.count
      report.page[:username].value("DNI: "+current_user.dni.to_s+", "+current_user.full_name)

      stocks.each do |stock|
        if report.page_count == 1 && report.list.overflow?
          report.start_new_page layout: :other_page do |page|
          end
        end
        
        report.list do |list|
          list.add_row do |row|
            row.values  product_code: stock.product_code,
                        product_name: stock.product_name,
                        area: stock.product_area_name,
                        quantity: stock.quantity
          end
        end
      end
      
      report.pages.each do |page|
        page[:title] = 'Reporte de stock disponible por rubros'
        page[:requested_date] = DateTime.now.strftime("%d/%m/%Y")
        page[:page_count] = report.page_count
      end

      report.list.on_page_footer_insert do |footer|
        footer.item(:total_label).show
        footer.item(:total_quantity).value(stocks.sum(&:quantity))
      end
  
      report.generate
    end
end
