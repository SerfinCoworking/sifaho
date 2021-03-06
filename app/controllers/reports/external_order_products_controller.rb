class Reports::ExternalOrderProductsController < ApplicationController
  before_action :set_external_order_product_report, only: [:show]

  def show
    authorize @external_order_product_report

    @movements = StockMovement.to_sector(@external_order_product_report.sector)
                              .with_product_ids(@external_order_product_report.products.ids)
                              .select('DISTINCT ON(stock_movements.order_id, stock_movements.lot_stock_id)
                              stock_movements.lot_stock_id, stock_movements.*')
                              .since_date(@external_order_product_report.since_date.strftime('%d/%m/%Y'))
                              .to_date(@external_order_product_report.to_date.strftime('%d/%m/%Y'))
                              .where(order_type: 'ExternalOrder')
                              .where(adds: false)
                              .order(:lot_stock_id, :order_id, created_at: :desc)

    respond_to do |format|
      format.html
      format.pdf do
        send_data generate_report(@movements, @params),
          filename: 'reporte_producto_por_paciente.pdf',
          type: 'application/pdf',
          disposition: 'inline'
      end
      format.xlsx { headers["Content-Disposition"] = "attachment; filename=\"ReporteProductoPorEstablecimiento_#{DateTime.now.strftime('%d-%m-%Y')}.xlsx\"" }
    end
  end

  def new
    authorize ExternalOrderProductReport
    @external_order_product_report = ExternalOrderProductReport.new
    @external_order_product_report.report_products.build
    @last_reports = ExternalOrderProductReport.where(sector_id: current_user.sector_id).limit(10).order(created_at: :desc)
  end

  def create
    @external_order_product_report = ExternalOrderProductReport.new(external_order_product_report_params)
    @external_order_product_report.created_by = current_user
    @external_order_product_report.sector = current_user.sector
    authorize @external_order_product_report

    respond_to do |format|
      if @external_order_product_report.save
        format.html { redirect_to reports_external_order_product_report_path(@external_order_product_report), notice: 'El reporte se ha creado correctamente.' }
      else
        @last_reports = ExternalOrderProductReport.limit(10)
        format.html { render :new }
      end
    end
  end

  private

  def set_external_order_product_report
    @external_order_product_report = ExternalOrderProductReport.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def external_order_product_report_params
    params.require(:external_order_product_report).permit(:product_id, :since_date, :to_date,
                                                          report_products_attributes: [:id, :product_id, :_destroy])
  end

  def generate_report(movements, params)
    report = Thinreports::Report.new layout: File.join(Rails.root, 'app', 'reports', 'external_order_product', 'first_page.tlf')
    
    report.use_layout File.join(Rails.root, 'app', 'reports', 'external_order_product', 'first_page.tlf'), :default => true
    report.use_layout File.join(Rails.root, 'app', 'reports', 'external_order_product', 'other_page.tlf'), id: :other_page
  
    movements.each do |movement|
      if report.page_count == 1 && report.list.overflow?
        report.start_new_page layout: :other_page do |page|
        end
      end
      
      # movement => {["last_name", "first_name", "dni", "dispensed_at"] => "delivered_quantity"} 
      report.list do |list|
        list.add_row do |row|
          row.values  establishment_name: movement.order_destiny_name,
                      quantity: movement.quantity
        end
      end
    end
    
    report.pages.each do |page|
      page[:product_name] = @external_order_product_report.product_name
      page[:title] = 'Reporte producto entregado por establecimiento'
      page[:date_now] = DateTime.now.strftime("%d/%m/%Y")
      page[:since_date] = @external_order_product_report.since_date.strftime("%d/%m/%Y")
      page[:to_date] = @external_order_product_report.to_date.strftime("%d/%m/%Y")
      page[:page_count] = report.page_count
      page[:establishment_name] = @external_order_product_report.sector.sector_and_establishment
      page[:establishment] = @external_order_product_report.establishment_name
      report.list.on_page_footer_insert do |footer|
        footer.item(:total_quantity).value(movements.sum(:quantity))
      end
    end

    report.generate
  end
end
