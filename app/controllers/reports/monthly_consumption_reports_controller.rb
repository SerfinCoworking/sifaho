class Reports::MonthlyConsumptionReportsController < ApplicationController
  before_action :set_monthly_consumption_report, only: [:show]

  def show
    authorize @monthly_consumption_report

    if @monthly_consumption_report.rubro?
      @stocks = Stock
        .to_sector(current_user.sector)
        .with_area_ids(@monthly_consumption_report.areas.ids)
        .reorder("products.name ASC")
        .joins(:product)
    else
      @stock_quantity = current_user.sector.stock_to(@monthly_consumption_report.product_id)
      stock = Stock.find_by(sector: current_user.sector, product_id: @monthly_consumption_report.product_id)
      if stock.present?
        @movements_average = stock
          .movements
          .where(adds: false)
          .since_date(@monthly_consumption_report.since_date.strftime("%d/%m/%Y"))
          .to_date(@monthly_consumption_report.to_date.strftime("%d/%m/%Y"))
          .group_by_month("stock_movements.created_at")
          .sum(:quantity)
        @month_average = @movements_average.sum { |x| x[1] } / @movements_average.size
      end
    end
      
    respond_to do |format|
      format.html
      format.pdf do
        send_data generate_report(@stocks, @params),
          filename: 'reporte_stock_por_rubro.pdf',
          type: 'application/pdf',
          disposition: 'inline'
      end
    end
  end

  def new
    authorize MonthlyConsumptionReport
    @monthly_consumption_report = MonthlyConsumptionReport.new
    @areas = Area.where(id: current_user.sector.stocks.joins(product: :area).pluck("areas.id").uniq)
    @last_reports = MonthlyConsumptionReport.where(sector_id: current_user.sector_id).limit(10).order(created_at: :desc)
  end

  def create
    @monthly_consumption_report = MonthlyConsumptionReport.new(monthly_consumption_report_params)
    @monthly_consumption_report.created_by = current_user
    @monthly_consumption_report.sector = current_user.sector
    authorize @monthly_consumption_report

    respond_to do |format|
      if @monthly_consumption_report.save
        format.html { redirect_to reports_monthly_consumption_report_path(@monthly_consumption_report), notice: 'El reporte se ha creado correctamente.' }
      else
        @areas = Area.where(id: current_user.sector.stocks.joins(product: :area).pluck("areas.id").uniq)
        @last_reports = MonthlyConsumptionReport.where(sector_id: current_user.sector_id).limit(10).order(created_at: :desc)
        format.html { render :new }
      end
    end
  end
  
  private
  
    def set_monthly_consumption_report
      @monthly_consumption_report = MonthlyConsumptionReport.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def monthly_consumption_report_params
      params.require(:monthly_consumption_report).permit(:since_date, :to_date, :report_type, :product_id, area_ids: [])
    end

    def generate_report(stocks, params)
      report = Thinreports::Report.new layout: File.join(Rails.root, 'app', 'reports', 'stock_quantity', 'first_page.tlf')
      
      report.use_layout File.join(Rails.root, 'app', 'reports', 'stock_quantity', 'first_page.tlf'), :default => true
      report.use_layout File.join(Rails.root, 'app', 'reports', 'stock_quantity', 'other_page.tlf'), id: :other_page
      
      report.start_new_page

      report.page[:supply_areas] = @monthly_consumption_report.areas.map(&:name).join(", ")
      report.page[:efector] = @monthly_consumption_report.sector.sector_and_establishment

      stocks.each do |stock|
        if report.page_count == 1 && report.list.overflow?
          report.start_new_page layout: :other_page do |page|
          end
        end
        
        report.list do |list|
          list.add_row do |row|
            row.values  product_code: stock.product_code,
                        product_name: stock.product_name,
                        supply_area: stock.product_area_name,
                        quantity: stock.quantity
          end
        end
      end
      
      report.pages.each do |page|
        page[:title] = 'Reporte de stock disponible por rubros'
        page[:date_now] = DateTime.now.strftime("%d/%m/%Y")
        page[:page_count] = report.page_count
      end

      report.list.on_page_footer_insert do |footer|
        footer.item(:total_label).show
        footer.item(:total_quantity).value(stocks.sum(&:quantity))
      end
  
      report.generate
    end
end
