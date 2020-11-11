class Reports::StockQuantityReportsController < ApplicationController
  before_action :set_stock_quantity_report, only: [:show]

  def show
    authorize @stock_quantity_report
    @movements = SectorSupplyLot
      .lots_for_sector(current_user.sector)
      .joins(:supply, :supply_area)
      .where(supplies: { supply_area_id: @stock_quantity_report.supply_areas.ids })
      .group("supplies.id", "supplies.name", "supply_areas.name")
      .sum("quantity")
      
    respond_to do |format|
      format.html
      format.pdf do
        send_data generate_report(@movements, @params),
          filename: 'reporte_stock_por_rubro.pdf',
          type: 'application/pdf',
          disposition: 'inline'
      end
      format.csv { send_data movements_to_csv(@movements), filename: "Reporte-#{Date.today.strftime('%d/%m/%Y')}.csv" }
      format.xls
    end
  end

  def new
    authorize StockQuantityReport
    @stock_quantity_report = StockQuantityReport.new
    @areas = SupplyArea.all
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
      params.require(:stock_quantity_report).permit(supply_area_ids: [])
    end

    def generate_report(movements, params)
      report = Thinreports::Report.new layout: File.join(Rails.root, 'app', 'reports', 'stock_quantity', 'first_page.tlf')
      
      report.use_layout File.join(Rails.root, 'app', 'reports', 'stock_quantity', 'first_page.tlf'), :default => true
      report.use_layout File.join(Rails.root, 'app', 'reports', 'stock_quantity', 'other_page.tlf'), id: :other_page
    
      movements.each do |movement|
        if report.page_count == 1 && report.list.overflow?
          report.start_new_page layout: :other_page do |page|
          end
        end
        
        # movement => {["supply_name", "supply_area"] => "quantity"} 
        report.list do |list|
          list.add_row do |row|
            row.values  product_code: movement.first.first,
                        product_name: movement.first.second,
                        supply_area: movement.first.third,
                        quantity: movement.second
          end
        end
      end
      
      report.pages.each do |page|
        page[:supply_areas] = @stock_quantity_report.supply_areas.map(&:name).join(", ")
        page[:title] = 'Reporte de stock disponible por rubros'
        page[:date_now] = DateTime.now.strftime("%d/%m/%Y")
        page[:page_count] = report.page_count
        page[:establishment_name] = @stock_quantity_report.sector.establishment_name
        page[:establishment] = @stock_quantity_report.sector.establishment_name
        report.list.on_page_footer_insert do |footer|
          footer.item(:total_quantity).value(movements.sum(&:second))
        end
      end
  
      report.generate
    end

    def movements_to_csv(movements)
      CSV.generate(headers: true) do |csv|
        csv << ["Codigo", "Producto", "Rubro", "Cantidad"]
        movements.each do |movement|
          csv << [
            movement.first.first,
            movement.first.second,
            movement.first.third,
            movement.second
          ]
        end
      end
    end
end
