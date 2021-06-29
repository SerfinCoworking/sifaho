class StateReports::PatientProductStateReportsController < ApplicationController
  before_action :set_patient_product_state_report, only: [:show]

  def show
    authorize @patient_product_state_report

    @movements = StockMovement.with_product_ids(@patient_product_state_report.products.ids)
                              .joins(:stock)
                              .since_date(@patient_product_state_report.since_date.strftime('%d/%m/%Y'))
                              .to_date(@patient_product_state_report.to_date.strftime('%d/%m/%Y'))
                              .where(order_type: ['OutpatientPrescription', 'ChronicPrescription'])
                              .where(adds: false)
                              .order(created_at: :desc)

    respond_to do |format|
      format.html
      format.pdf do
        send_data generate_report(@movements, @params),
                  filename: 'reporte_producto_por_paciente.pdf',
                  type: 'application/pdf',
                  disposition: 'inline'
      end
      format.xlsx { headers['Content-Disposition'] = "attachment; filename=\"ReporteProductoPorPacienteProvincia_#{DateTime.now.strftime('%d-%m-%Y')}.xlsx\"" }
    end
  end

  def new
    authorize PatientProductStateReport
    @patient_product_state_report = PatientProductStateReport.new
    @patient_product_state_report.report_products.build
    @last_reports = PatientProductStateReport.limit(5).order(created_at: :desc)
  end

  def create
    @patient_product_state_report = PatientProductStateReport.new(patient_product_state_report_params)
    @patient_product_state_report.created_by = current_user
    authorize @patient_product_state_report

    respond_to do |format|
      if @patient_product_state_report.save
        format.html { redirect_to state_reports_patient_product_state_report_path(@patient_product_state_report), notice: 'El reporte se ha creado correctamente.'}
      else
        @last_reports = PatientProductStateReport.limit(5).order(created_at: :desc)
        format.html { render :new }
      end
    end
  end

  def load_more
    @next_offset = PatientProductStateReport.offset(params[:offset]).count > 5 ? params[:offset].to_i + 5 : 0
    @last_reports = PatientProductStateReport.offset(params[:offset]).limit(5).order(created_at: :desc)
    respond_to do |format|
      format.js
    end
  end

  private

  def set_patient_product_state_report
    @patient_product_state_report = PatientProductStateReport.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def patient_product_state_report_params
    params.require(:patient_product_state_report).permit(:product_id, :since_date, :to_date,
      report_products_attributes: [:id, :product_id, :_destroy])
  end

  def generate_report(movements, params)
    report = Thinreports::Report.new layout: File.join(Rails.root, 'app', 'reports', 'internal_order_product', 'first_page.tlf')

    report.use_layout File.join(Rails.root, 'app', 'reports', 'internal_order_product', 'first_page.tlf'), default: true
    report.use_layout File.join(Rails.root, 'app', 'reports', 'internal_order_product', 'other_page.tlf'), id: :other_page

    movements.each do |movement|
      if report.page_count == 1 && report.list.overflow?
        report.start_new_page layout: :other_page do |page|
        end
      end

      # movement => {["last_name", "first_name", "dni", "dispensed_at"] => "delivered_quantity"}
      report.list do |list|
        list.add_row do |row|
          row.values  sector_name: movement.first,
                      quantity: movement.second
        end
      end
    end

    report.pages.each do |page|
      page[:product_name] = @patient_product_state_report.supply_name
      page[:title] = 'Reporte producto entregado por sectores'
      page[:date_now] = DateTime.now.strftime('%d/%m/%Y')
      page[:since_date] = @patient_product_state_report.since_date.strftime('%d/%m/%Y')
      page[:to_date] = @patient_product_state_report.to_date.strftime('%d/%m/%Y')
      page[:page_count] = report.page_count
      page[:establishment_name] = @patient_product_state_report.establishment_name
      page[:establishment] = @patient_product_state_report.establishment_name
    end

    report.generate
  end
end
