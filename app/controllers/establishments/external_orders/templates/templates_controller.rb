class Establishments::ExternalOrders::Templates::TemplatesController < ApplicationController

  before_action :set_template, only: %i[show edit update destroy use_applicant use_provider build_from_template]

  # GET /external_order_templates
  # GET /external_order_templates.json
  def index
    authorize ExternalOrderTemplate
    @applicant_templates = ExternalOrderTemplate.where(owner_sector: current_user.sector).solicitud
    @provider_templates = ExternalOrderTemplate.where(owner_sector: current_user.sector).provision
  end

  # GET /external_order_templates/1
  # GET /external_order_templates/1.json
  def show
    authorize @external_order_template
    respond_to do |format|
      format.html
      format.pdf do
        pdf = ReportServices::ExternalOrderTemplateReportService.new(current_user, @external_order_template).call
        send_data pdf, filename: "Plantilla_#{@external_order_template.order_type}.pdf", type: 'application/pdf', disposition: 'inline'
      end
    end
  end


  # DELETE /external_order_templates/1
  # DELETE /external_order_templates/1.json
  def destroy
    authorize @external_order_template
    @external_order_template.destroy
    respond_to do |format|
      format.html { redirect_to external_orders_templates_url, notice: 'La plantilla se ha eliminado correctamente.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_template
    @external_order_template = ExternalOrderTemplate.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def external_order_template_params
    params.require(:external_order_template).permit(
      :name,
      :owner_sector_id,
      :destination_sector_id,
      :destination_establishment_id,
      :observation, 
      :order_type,
      external_order_product_templates_attributes:
      [ 
        :id,
        :product_id,
        :_destroy 
      ]
    )
  end
end
