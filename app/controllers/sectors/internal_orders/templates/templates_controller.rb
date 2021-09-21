class Sectors::InternalOrders::Templates::TemplatesController < ApplicationController
  before_action :set_internal_order_template, only: %i[show edit update destroy]

  # GET /sectors/internal_orders/templates/templates
  # GET /sectors/internal_orders/templates/templates.json
  def index
    authorize InternalOrderTemplate
    @applicant_templates = InternalOrderTemplate.where(owner_sector: current_user.sector).solicitud
    @provider_templates = InternalOrderTemplate.where(owner_sector: current_user.sector).provision
  end

  # GET /sectors/internal_orders/templates/templates/1
  # GET /sectors/internal_orders/templates/templates/1.json
  def show
    authorize @internal_order_template
    respond_to do |format|
      format.html
      format.pdf do
        pdf = ReportServices::InternalOrderTemplateReportService.new(current_user, @internal_order_template).generate_pdf
        send_data pdf, filename: "Plantilla_#{@internal_order_template.order_type}_sector.pdf", type: 'application/pdf', disposition: 'inline'
      end
    end
  end

  # DELETE /sectors/internal_orders/templates/templates/1
  # DELETE /sectors/internal_orders/templates/templates/1.json
  def destroy
    authorize @internal_order_template
    @internal_order_template.destroy
    respond_to do |format|
      format.html { redirect_to internal_orders_templates_url(@internal_order_template), notice: 'La plantilla se ha eliminado correctamente.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_internal_order_template
    @internal_order_template = InternalOrderTemplate.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def internal_order_template_params
    params.require(:internal_order_template).permit(:name, :owner_sector_id, :destination_sector_id, :observation,
                                                    :order_type,
                                                    internal_order_product_templates_attributes: [:id, :product_id,
                                                                                                  :_destroy])
  end
end
  