class Sectors::InternalOrders::InternalOrderController < ApplicationController

  # def statistics
  #   @internal_providers = InternalOrder.provider(current_user.sector)
  #   @internal_applicants = InternalOrder.applicant(current_user.sector)
  # end

  # GET /internal_orders/1
  # GET /internal_orders/1.json
  def show
    authorize @internal_order
    respond_to do |format|
      format.html
      format.js
      format.pdf do
        pdf = ReportServices::InternalOrderReportService.new(current_user, @internal_order).generate_pdf
        send_data pdf, filename: "Pedido_#{@internal_order.remit_code}.pdf", type: 'application/pdf', disposition: 'inline'
      end
    end
  end

  # DELETE /internal_orders/1
  # DELETE /internal_orders/1.json
  def destroy
    @internal_order.destroy
    respond_to do |format|
      @internal_order.create_notification(current_user, 'se eliminó correctamente')
      flash.now[:success] = 'El pedido interno de se ha eliminado correctamente.'
      format.js
    end
  end

  def set_order_product
    @order_product = params[:order_product_id].present? ? InternalOrderProduct.find(params[:order_product_id]) : InternalOrderProduct.new
  end

  protected

  # Use callbacks to share common setup or constraints between actions.
  def set_internal_order
    @internal_order = InternalOrder.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def internal_order_params
    params.require(:internal_order).permit(
      :applicant_sector_id,
      :order_type,
      :provider_sector_id,
      :observation
    )
  end
end
