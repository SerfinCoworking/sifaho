class ExternalOrdersController < ApplicationController
  before_action :set_external_order, only: [:show, :send_provider, :send_applicant, :destroy, :delete, :return_applicant_status, :return_provider_status, :edit_provider, :edit_applicant,
    :update_applicant, :update_provider, :accept_provider, :receive_applicant_confirm, :receive_applicant, :receive_applicant, :nullify, :nullify_confirm ]

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

  # GET /external_orders
  # GET /external_orders.json
  def provider_index
    authorize ExternalOrder
    @filterrific = initialize_filterrific(
      ExternalOrder.provider(current_user.sector).without_status(0),
      params[:filterrific],
      select_options: {
        with_status: ExternalOrder.options_for_status
      },
      persistence_id: false,
    ) or return
    @external_orders = @filterrific.find.page(params[:page]).per_page(15)
  end

  # GET /external_orders
  # GET /external_orders.json
  def applicant_index
    authorize ExternalOrder
    @filterrific = initialize_filterrific(
      ExternalOrder.applicant(current_user.sector),
      params[:filterrific],
      select_options: {
        sorted_by: ExternalOrder.options_for_sorted_by,
        with_status: ExternalOrder.options_for_status
      },
      persistence_id: false
    ) or return
    @applicant_orders = @filterrific.find.page(params[:page]).per_page(15)
  end

  # GET /external_orders/1
  # GET /external_orders/1.json
  def show
    authorize @external_order

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        send_data generate_order_report(@external_order),
          filename: 'Despacho_'+@external_order.remit_code+'.pdf',
          type: 'application/pdf',
          disposition: 'inline'
      end
    end
  end


  # GET /external_orders/new
  def new_report
    authorize ExternalOrder
    @external_order = ExternalOrder.new
    @establishments = ExternalOrder.provided_establishments_by(current_user.sector)
  end

  # GET /external_orders/new_applicant
  def new_applicant
    authorize ExternalOrder
    @external_order = ExternalOrder.new
    @external_order.order_type = 'solicitud'
    @sectors = []
    @external_order.external_order_products.build
  end
  
  # GET /external_orders/new_provider
  def new_provider
    authorize ExternalOrder
    @external_order = ExternalOrder.new
    @external_order.order_type = 'provision'
    @sectors = []
    @external_order.external_order_products.build
  end

  # GET /external_orders/1/edit
  def edit_provider
    authorize @external_order
    @external_order.external_order_products || @external_order.external_order_products.build
    @sectors = @external_order.applicant_sector.present? ? @external_order.applicant_establishment.sectors : []
  end

  # GET /external_orders/1/edit_applicant
  def edit_applicant
    authorize @external_order
    @external_order.external_order_products || @external_order.external_order_products.build
    @sectors = @external_order.provider_sector.present? ? @external_order.provider_establishment.sectors : []
  end

  # Creación despacho o recibo
  # POST /external_orders
  # POST /external_orders.json
  def create_applicant
    @external_order = ExternalOrder.new(external_order_params)
    authorize @external_order
    @external_order.requested_date = DateTime.now
    @external_order.applicant_sector = current_user.sector
    @external_order.order_type = "solicitud"
    @external_order.status = sending? ? "solicitud_enviada" : "solicitud_auditoria"

    respond_to do |format|
      @external_order.save!
      begin
        message = sending? ? "La solicitud de abastecimiento se ha creado y enviado correctamente." : "La solicitud de abastecimiento se ha creado y se encuentra en auditoría."
        notification_type = sending? ? "creó y envió" : "creó y auditó"

        @external_order.create_notification(current_user, notification_type)        

        format.html { redirect_to @external_order, notice: message }
      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @external_order_products = @external_order.external_order_products.present? ? @external_order.external_order_products : @external_order.external_order_products.build
        @sectors = @external_order.provider_sector.present? ? @external_order.provider_establishment.sectors : []
        format.html { render :new_applicant }
      end
    end
  end

  # PATCH /external_orders
  # PATCH /external_orders.json
  def create_provider
    @external_order = ExternalOrder.new(external_order_params)
    authorize @external_order
    @external_order.requested_date = DateTime.now
    @external_order.provider_sector = current_user.sector
    @external_order.order_type = "provision"
    @external_order.status = accepting? ? "proveedor_aceptado" : 'proveedor_auditoria'
        
    respond_to do |format|
      begin
        @external_order.save!
        message = accepting? ? 'La provisión se ha creado y aceptado correctamente.' : "La provisión se ha creado y se encuentra en auditoria."
        notification_type = accepting? ? "creó y aceptó" : "creó"
        @external_order.create_notification(current_user, notification_type)     

        format.html { redirect_to @external_order, notice: message }
      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @external_order.external_order_products || @external_order.external_order_products.build
        @sectors = @external_order.provider_sector.present? ? @external_order.provider_establishment.sectors : []
        format.html { render :new_provider }
      end
    end
  end

  # PATCH /external_orders
  # PATCH /external_orders.json
  def update_applicant
    authorize @external_order
    @external_order.status = sending? ? "solicitud_enviada" : "solicitud_auditoria"

    respond_to do |format|
      begin
        @external_order.update(external_order_params)
        @external_order.save!

        message = sending? ? "La solicitud se ha auditado y enviado correctamente." : "La solicitud se ha auditado y se encuentra en auditoria."
        notification_type = sending? ? "auditó y envió" : "auditó"

        @external_order.create_notification(current_user, notification_type)        

        format.html { redirect_to @external_order, notice: message }
      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @external_order_products = @external_order.external_order_products.present? ? @external_order.external_order_products : @external_order.external_order_products.build
        @sectors = @external_order.provider_sector.present? ? @external_order.provider_establishment.sectors : []
        format.html { render :edit_applicant }
      end
    end
  end

  # PATCH /external_orders
  # PATCH /external_orders.json
  def update_provider
    authorize @external_order
    @external_order.status = accepting? ? "proveedor_aceptado" : 'proveedor_auditoria'
        
    respond_to do |format|
      begin
        @external_order.update!(external_order_params)
        message = accepting? ? 'La provisión se ha auditado y aceptado correctamente.' : "La provisión se ha auditado y se encuentra en auditoria."
        notification_type = accepting? ? "auditó y aceptó" : "auditó"
        @external_order.create_notification(current_user, notification_type)     

        format.html { redirect_to @external_order, notice: message }
      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @external_order.external_order_products || @external_order.external_order_products.build
        @sectors = @external_order.provider_sector.present? ? @external_order.provider_establishment.sectors : []
        format.html { render :edit_provider }
      end
    end
  end

  # GET /external_orders/1/send_provider
  def send_provider
    authorize @external_order
    
    respond_to do |format|
      begin
        @external_order.provision_en_camino!
        @external_order.send_order_by(current_user)        

        format.html { redirect_to @external_order, notice: 'La provision se ha enviado correctamente.' }
      rescue ArgumentError => e
        # si fallo la validación de stock, debemos volver atras el estado de la orden
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @external_order.external_order_products || @external_order.external_order_products.build
        @sectors = @external_order.provider_sector.present? ? @external_order.provider_establishment.sectors : []
        format.html { render :edit_provider }
      end
    end
  end

  # GET /external_orders/1/accept_provider
  def accept_provider
    authorize @external_order
    respond_to do |format|
      begin
        @external_order.proveedor_aceptado!
      rescue ArgumentError => e
        flash[:alert] = e.message
      else
        @external_order.create_notification(current_user, "aceptó")
        flash[:notice] = 'La provisión ha sido aceptado correctamente.'
      end
      format.html { render :show }
    end
  end

  # GET /external_orders/1/receive_applicant
  def receive_applicant
    authorize @external_order
    respond_to do |format|
      begin
        unless @external_order.provision_en_camino?; raise ArgumentError, 'La provisión aún no está en camino.'; end
        @external_order.receive_order_by(current_user)
        flash[:success] = 'La '+@external_order.order_type+' se ha recibido correctamente'
      rescue ArgumentError => e
        flash[:error] = e.message
      end
      format.html { redirect_to @external_order }
    end
  end

  def return_applicant_status
    authorize @external_order
    respond_to do |format|
      begin
        @external_order.return_applicant_status_by(current_user)
        flash[:notice] = 'La solicitud se ha retornado a un estado anterior.'
      rescue ArgumentError => e
        flash[:alert] = e.message
      end
      format.html { redirect_to @external_order }
    end
  end

  # GET /external_orders/1/send_applicant
  def send_applicant
    authorize @external_order
    @external_order.send_request_by(current_user)
    respond_to do |format|
      flash[:success] = "La solicitud se ha enviado correctamente."
      format.html { redirect_to @external_order }
    end
  end
  
  def return_provider_status
    authorize @external_order
    respond_to do |format|
      begin
        @external_order.proveedor_auditoria!
      rescue ArgumentError => e
        flash[:alert] = e.message
      else
        @external_order.create_notification(current_user, "retornó a un estado anterior")
        flash[:notice] = 'El pedido se ha retornado a un estado anterior.'
      end
      format.html { redirect_to @external_order }
    end
  end

  # DELETE /external_orders/1
  # DELETE /external_orders/1.json
  def destroy
    authorize @external_order
    @sector_name = @external_order.applicant_sector.name
    @order_type = @external_order.order_type
    Notification.destroy_with_target_id(@external_order.id)
    @external_order.destroy
    @external_order.create_notification(current_user, "envió a la papelera")
    respond_to do |format|
      flash.now[:success] = @order_type.humanize+" de "+@sector_name+" se ha enviado a la papelera."
      format.js
    end
  end

  # GET /external_order/1/delete
  def delete
    authorize @external_order
    respond_to do |format|
      format.js
    end
  end

  def generate_report
    authorize ExternalOrder
    respond_to do |format|
      if params[:external_order][:since_date].present? && params[:external_order][:to_date].present?
        @report_type = "2"
        @since_date = DateTime.parse(params[:external_order][:since_date])
        @to_date = DateTime.parse(params[:external_order][:to_date])
        if params[:external_order][:applicant_sector_id].present?
          @applicant_establishment = Establishment.find(params[:external_order][:applicant_sector_id])
          @filtered_orders = ExternalOrder.applicant_establishment(@applicant_establishment).requested_date_since(@since_date).requested_date_to(@to_date).without_status(0)
          @supplies = Array.new
          @filtered_orders.each do |ord|
            @supplies.concat(ord.quantity_ord_supply_lots.pluck(:supply_id, :delivered_quantity))
          end
          @supplies = @supplies.group_by(&:first).map { |k, v| [k, v.map(&:last).inject(:+)] }
        else
          @report_type = "1"
          @filtered_orders = ExternalOrder.provider(current_user.sector).requested_date_since(@since_date).requested_date_to(@to_date).without_status(0).joins(:applicant_establishment).group('establishments.name').count
        end
        flash.now[:success] = "Reporte generado."
        format.html { render :generate_report}
      else
        @report_type = "1"
        @external_order = ExternalOrder.new
        flash.now[:error] = "Verifique los campos."
        format.html { render :new_report }
      end  
    end
  end

  # patch /external_order/1/nullify
  def nullify
    authorize @external_order
    @external_order.nullify_by(current_user)
    respond_to do |format|
      flash[:success] = "#{@external_order.order_type.humanize} se ha anulado correctamente."
      format.html { redirect_to @external_order }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_external_order
      @external_order = ExternalOrder.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def external_order_params
      params.require(:external_order).permit(:applicant_sector_id, 
      :sent_by_id, 
      :order_type,
      :provider_sector_id, 
      :requested_date, 
      :date_received, 
      :observation, 
      :remit_code,
      external_order_products_attributes: [
        :id, 
        :product_id, 
        :lot_stock_id,
        :request_quantity,
        :delivery_quantity,
        :applicant_observation,
        :provider_observation, 
        :_destroy,
        order_prod_lot_stocks_attributes: [
          :id,
          :quantity,
          :lot_stock_id,
          :_destroy
        ]
      ])
    end

    def accepting?
      return params[:commit] == "accepting"
    end

    def receiving?
      submit = params[:commit]
      return submit == "Recibir" || submit == "Auditar y recibir"
    end

    def sending?
      return params[:commit] == "sending"
    end
end
