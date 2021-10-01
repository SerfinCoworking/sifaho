class Establishments::ExternalOrders::ExternalOrdersController < ApplicationController

  def statistics
    @external_orders = ExternalOrder.all
    @requests_sent = ExternalOrder.applicant(current_user.sector).solicitud_abastecimiento.group(:status).count.transform_keys { |key| key.split('_').map(&:capitalize).join(' ') }
    status_colors = { "Recibo Realizado" => "#40c95e", "Provision Entregada" => "#40c95e", "Solicitud Auditoria" => "#f1ae45", "Proveedor Aceptado" => "#336bb6", 
      "Recibo Auditoria" => "#f1ae45", "Provision En Camino" => "#336bb6", "Proveedor Auditoria" => "#f1ae45", "Vencido" => "#d36262", "Solicitud Enviada" => "#5bbae1" }
    @r_s_colors = []
    @requests_sent.each do |status, _|
      @r_s_colors << status_colors[status]
    end
    @requests_received = ExternalOrder.provider(current_user.sector).solicitud_abastecimiento.group(:status).count.transform_keys { |key| key.split('_').map(&:capitalize).join(' ') }
    @r_r_colors = []
    @requests_received.each do |status, _|
      @r_r_colors << status_colors[status]
    end
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
      :provider_observation,
      :applicant_observation
    )
  end
end
