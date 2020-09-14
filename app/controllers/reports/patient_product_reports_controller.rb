class Reports::PatientProductReportsController < ApplicationController

  # GET /patient_product_reports/new
  def new
  end

  # POST /patient_product_reports
  # POST /patient_product_reports.json
  def create
    @patient_product_report = PatientProductReport.new(patient_product_report_params)

    respond_to do |format|
      if @patient_product_report.save
        format.html { redirect_to @patient_product_report, notice: 'Patient product report was successfully created.' }
        format.json { render :show, status: :created, location: @patient_product_report }
      else
        format.html { render :new }
        format.json { render json: @patient_product_report.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def patient_product_report_params
      params.require(:patient_product_report).permit(:supply_id, :since_date, :to_date)
    end
end
