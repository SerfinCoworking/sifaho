class ReportsController < ApplicationController
  before_action :set_report, only: [:show]

  def index
    @filterrific = initialize_filterrific(
      Report.to_sector(current_user.sector),
      params[:filterrific],
      select_options: {
        sorted_by: Report.options_for_sorted_by,
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'created_at_desc'},
      available_filters: [
        :sorted_by
      ],
    ) or return
    @reports = @filterrific.find.page(params[:page]).per_page(15)
  end

  def show
    authorize @report

    if @report.delivered_by_order?
      @pres_consumption = current_user.sector.sum_delivered_prescription_quantities_to(@report.supply_id, @report.since_date, @report.to_date) 
      @int_ord_consumption = current_user.sector.sum_delivered_internal_quantities_to(@report.supply_id, @report.since_date, @report.to_date)
      @ord_sup_consumption = current_user.sector.sum_delivered_ordering_supply_quantities_to(@report.supply_id, @report.since_date, @report.to_date)
      @total_sum = @pres_consumption + @int_ord_consumption + @ord_sup_consumption
    elsif @report.delivered_by_establishment?
      @quantities = current_user.sector.delivered_ordering_supply_quantities_by_establishment_to(@report.supply_id)
    end
  end

  # GET /reports/new_delivered_by_order
  def new_delivered_by_order
    authorize Report
    @report = Report.new
    @report.report_type = 0
  end

  # GET /reports/new_delivered_by_establishment
  def new_delivered_by_establishment
    authorize Report
    @report = Report.new
    @report.report_type = 1
  end

  # POST /reports/create_delivered_by_order
  def create_delivered_by_order
    @report = Report.new(report_params)
    authorize @report

    @report.sector = current_user.sector
    @report.user = current_user
    @report.name = "Reporte de insumo entregado por pedido"

    respond_to do |format|
      if @report.save
        flash.now[:success] = @report.name+" se ha creado correctamente."
        format.html { redirect_to @report }
      else
        flash.now[:error] = "El reporte no se ha podido crear."
        format.html { render :new_delivered_by_order }
      end
    end
  end

  # POST /reports/create_delivered_by_establisment
  def create_delivered_by_establishment
    @report = Report.new(report_params)
    authorize @report

    @report.sector = current_user.sector
    @report.user = current_user
    @report.report_type = 1
    @report.name = "Reporte de insumo entregado por establecimiento."

    respond_to do |format|
      if @report.save
        flash.now[:success] = @report.name+" se ha creado correctamente."
        format.html { redirect_to @report }
      else
        flash.now[:error] = "El reporte no se ha podido crear."
        format.html { render :new_delivered_by_establishment }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_report
      @report = Report.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def report_params
      params.require(:report).permit(:id, :since_date, :to_date, :supply_id,)
    end
end