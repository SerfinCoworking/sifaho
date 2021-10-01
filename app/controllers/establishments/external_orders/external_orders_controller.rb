class Establishments::ExternalOrders::ExternalOrdersController < ApplicationController

  def summary
    @orders_this_month = ExternalOrder.requested_date_since(DateTime.today.beginning_of_month)

    @requested_orders_in_road = ExternalOrder.applicant(current_user.sector)
    render 'establishments/external_orders/summary'
  end

  # GET /external_orders/1
  # GET /external_orders/1.json
  def show
    authorize @external_order
    respond_to do |format|
      format.html
      format.js
      format.pdf do
        pdf = ReportServices::ExternalOrderReportService.new(current_user, @external_order).generate_pdf
        send_data pdf, filename: "Pedido_#{@external_order.remit_code}.pdf", type: 'application/pdf', disposition: 'inline'
      end
    end
  end

  def destroy
    @sector_name = @external_order.applicant_sector.name
    @order_type = @external_order.order_type
    Notification.destroy_with_target_id(@external_order.id)
    @external_order.destroy
    @external_order.create_notification(current_user, 'envió a la papelera')
    respond_to do |format|
      flash.now[:success] = "#{@order_type.humanize} de #{@sector_name} se ha enviado a la papelera."
      format.js
    end
  end

  protected
  # Use callbacks to share common setup or constraints between actions.
  def set_external_order
    @external_order = ExternalOrder.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def external_order_params
    params.require(:external_order).permit(
      :applicant_sector_id,
      :order_type,
      :provider_sector_id, 
      :requested_date, 
      :date_received, 
      :observation
    )
  end
end
