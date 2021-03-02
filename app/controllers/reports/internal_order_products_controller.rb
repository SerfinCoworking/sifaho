class Reports::InternalOrderProductsController < ApplicationController
  before_action :set_internal_order_product_report, only: [:show]

  def show
    authorize @internal_order_product_report
    @movements =  Stock
      .where(sector: current_user.sector, product_id: @internal_order_product_report.product_id).first
      .movements
      .with_product_ids(@internal_order_product_report.product_id)
      .since_date(@internal_order_product_report.since_date.strftime("%d/%m/%Y"))
      .to_date(@internal_order_product_report.to_date.strftime("%d/%m/%Y"))
      .where(order_type: 'InternalOrder')
      .order(created_at: :desc)
    
    respond_to do |format|
      format.html
      format.pdf do
        send_data generate_report(@movements, @params),
          filename: 'reporte_producto_por_paciente.pdf',
          type: 'application/pdf',
          disposition: 'inline'
      end
      format.xlsx { headers["Content-Disposition"] = "attachment; filename=\"ReporteProductoPorSector_#{DateTime.now.strftime('%d-%m-%Y')}.xlsx\"" }
    end
  end

  def new
    authorize InternalOrderProductReport
    @internal_order_product_report = InternalOrderProductReport.new
    @last_reports = InternalOrderProductReport.where(sector_id: current_user.sector_id).limit(10).order(created_at: :desc)
  end

  def create
    @internal_order_product_report = InternalOrderProductReport.new(internal_order_product_report_params)
    @internal_order_product_report.created_by = current_user
    @internal_order_product_report.sector = current_user.sector
    authorize @internal_order_product_report

    respond_to do |format|
      if @internal_order_product_report.save
        format.html { redirect_to reports_internal_order_product_report_path(@internal_order_product_report), notice: 'El reporte se ha creado correctamente.' }
      else
        @last_reports = InternalOrderProductReport.limit(10)
        format.html { render :new }
      end
    end
  end
  
  private
  
    def set_internal_order_product_report
      @internal_order_product_report = InternalOrderProductReport.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def internal_order_product_report_params
      params.require(:internal_order_product_report).permit(:supply_id, :since_date, :to_date)
    end

    def generate_report(movements, params)
      report = Thinreports::Report.new layout: File.join(Rails.root, 'app', 'reports', 'internal_order_product', 'first_page.tlf')
      
      report.use_layout File.join(Rails.root, 'app', 'reports', 'internal_order_product', 'first_page.tlf'), :default => true
      report.use_layout File.join(Rails.root, 'app', 'reports', 'internal_order_product', 'other_page.tlf'), id: :other_page
    
      movements.each_with_index do |movement, index|
        if report.page_count == 1 && report.list.overflow?
          report.start_new_page layout: :other_page do |page|
          end
        end
        
        # movement => {["last_name", "first_name", "dni", "dispensed_at"] => "delivered_quantity"} 
        report.list do |list|
          list.add_row do |row|
            row.values  line_index: index,
                        date: movement.created_at.strftime("%d/%m/%Y"),
                        sector_name: movement.order_destiny_name,
                        quantity: movement.quantity
          end
        end
      end
      
  
      report.pages.each do |page|
        page[:product_name] = @internal_order_product_report.supply_name
        page[:title] = 'Reporte producto entregado por sectores'
        page[:date_now] = DateTime.now.strftime("%d/%m/%Y")
        page[:since_date] = @internal_order_product_report.since_date.strftime("%d/%m/%Y")
        page[:to_date] = @internal_order_product_report.to_date.strftime("%d/%m/%Y")
        page[:page_count] = report.page_count
        page[:establishment_name] = @internal_order_product_report.establishment_name
        page[:establishment] = @internal_order_product_report.establishment_name
      end
  
      report.generate
    end

    def movements_to_csv(movements, options = {})
      CSV.generate(header: true) do |csv|
        csv << ["Sector", "Cantidad", "Producto"]
        movements.each do |movement|
          csv << [
            movement.first,
            movement.second,
            @internal_order_product_report.supply_name
          ]
        end
      end
    end
end
