class ExternalOrdersController < ApplicationController
  before_action :set_external_order, only: [:show, :edit, :update, :send_provider,
    :send_applicant, :destroy, :delete, :return_status, :edit_receipt, :edit_applicant,
    :receive_applicant_confirm, :receive_applicant, :receive_order, :receive_order_confirm, :nullify, :nullify_confirm ]

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
  def index
    authorize ExternalOrder
    @filterrific = initialize_filterrific(
      ExternalOrder.provider(current_user.sector).without_status(0).without_order_type(2),
      params[:filterrific],
      select_options: {
        sorted_by: ExternalOrder.options_for_sorted_by,
        with_status: ExternalOrder.options_for_status
      },
      persistence_id: false
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
  def new
    authorize ExternalOrder
    @external_order = ExternalOrder.new
    @order_type = 'despacho'
  end

  # GET /external_orders/new_receipt
  def new_receipt
    authorize ExternalOrder
    @external_order = ExternalOrder.new
    @order_type = 'recibo'
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
    @order_type = 'solicitud_abastecimiento'
  end

  # GET /external_orders/1/edit
  def edit
    authorize @external_order
    @order_type = 'despacho'
    @external_order.quantity_ord_supply_lots || @external_order.quantity_ord_supply_lots.build
    @sectors = Sector.with_establishment_id(@external_order.applicant_sector.establishment_id)
  end

  # GET /external_orders/1/edit_receipt
  def edit_receipt
    authorize @external_order
    @order_type = 'recibo'
    @external_order.quantity_ord_supply_lots || @external_order.quantity_ord_supply_lots.build
    @sectors = Sector.with_establishment_id(@external_order.provider_sector.establishment_id)
  end

  # GET /external_orders/1/edit_applicant
  def edit_applicant
    authorize @external_order
    @order_type = 'solicitud_abastecimiento'
    @external_order.quantity_ord_supply_lots || @external_order.quantity_ord_supply_lots.build
    @sectors = Sector.with_establishment_id(@external_order.provider_sector.establishment_id)
  end

  # Creación despacho o recibo
  # POST /external_orders
  # POST /external_orders.json
  def create
    @external_order = ExternalOrder.new(external_order_params)
    authorize @external_order
    @external_order.created_by = current_user
    @external_order.audited_by = current_user
    respond_to do |format|
      if @external_order.save
        begin
          if @external_order.despacho?
            @external_order.proveedor_auditoria!
            # Si se acepta el despacho
            if accepting?
              @external_order.accept_order(current_user)
              @external_order.create_notification(current_user, "creó y aceptó")
              flash[:success] = 'El despacho se ha creado y aceptado correctamente'
            else
              @external_order.create_notification(current_user, "creó")
              flash[:notice] = 'El despacho se ha creado y se encuentra en auditoría.'
            end
          elsif @external_order.recibo?
            @external_order.recibo! # Se asigna el tipo recibo
            @external_order.recibo_auditoria! # Se asigna el estado recibo auditoria
            if receiving?
              @external_order.receive_remit(current_user)
              @external_order.create_notification(current_user, "creó y realizó")
              flash[:success] = 'El recibo se ha creado y realizado correctamente'
            else
              @external_order.create_notification(current_user, "creó")
              flash[:notice] = 'El recibo se ha creado y se encuentra en auditoría.'
            end
          elsif @external_order.solicitud_abastecimiento?
            @external_order.solicitud_abastecimiento! # Se asigna el tipo solicitud abastecimiento.
            @external_order.solicitud_auditoria!
            if sending?
              @external_order.send_request_of(current_user)
              @external_order.create_notification(current_user, "creó y envió")
              flash[:success] = 'La solicitud de abastecimiento se ha creado y enviado correctamente'
            else
              @external_order.create_notification(current_user, "creó")
              flash[:notice] = 'La solicitud de abastecimiento se ha creado y se encuentra en auditoría.'
            end
          end
        rescue ArgumentError => e
          flash[:alert] = e.message
          if external_order_params[:order_type] == 'despacho'
            @order_type = 'despacho'
            @sectors = Sector.with_establishment_id(@external_order.applicant_sector.establishment_id)
            format.html { render :new }
          elsif external_order_params[:order_type] == 'recibo'
            @order_type = 'recibo'
            @sectors = Sector.with_establishment_id(@external_order.provider_sector.establishment_id)
            format.html { render :new_receipt }
          elsif external_order_params[:order_type] == 'solicitud_abastecimiento'
            @order_type = 'solicitud_abastecimiento'
            @sectors = Sector.with_establishment_id(@external_order.provider_sector.establishment_id)
            format.html { render :new_applicant }
          end
        else
          format.html { redirect_to @external_order }
        end
      else
        if external_order_params[:order_type] == 'despacho'
          @order_type = 'despacho'
          @external_order.applicant_sector.present? ? @sectors = Sector.with_establishment_id(@external_order.applicant_sector.establishment_id) : ""
          flash[:error] = "El despacho no se ha podido crear."
          format.html { render :new }
        elsif external_order_params[:order_type] == 'recibo'
          @order_type = 'recibo'
          @external_order.provider_sector.present? ? @sectors = Sector.with_establishment_id(@external_order.provider_sector.establishment_id) : ""
          flash[:error] = "El recibo no se ha podido crear."
          format.html { render :new_receipt }
        elsif external_order_params[:order_type] == 'solicitud_abastecimiento'
          @order_type = 'solicitud_abastecimiento'
          @external_order.provider_sector.present? ? @sectors = Sector.with_establishment_id(@external_order.provider_sector.establishment_id) : ""
          flash[:error] = "La solicitud de abastecimiento no se ha podido crear."
          format.html { render :new_applicant }
        end
      end
    end
  end

  # PATCH/PUT /external_orders/1
  # PATCH/PUT /external_orders/1.json
  def update
    authorize @external_order
    respond_to do |format|
      if @external_order.update(external_order_params)
        begin
          if @external_order.despacho?  
            if accepting? # Si se acepta el despacho
              @external_order.accept_order(current_user)
              @external_order.create_notification(current_user, "auditó y aceptó")
              flash[:success] = 'El despacho se ha auditado y aceptado correctamente'
            elsif sending? # Si se envía el despacho
              @external_order.send_order(current_user)
              @external_order.create_notification(current_user, "auditó y envió")
              flash[:success] = 'El despacho se ha auditado y enviado correctamente'
            else
              @external_order.create_notification(current_user, "auditó")
              flash[:success] = 'El despacho se ha auditado correctamente'
            end
          elsif @external_order.recibo?
            if receiving?
              @external_order.receive_remit(current_user)
              @external_order.create_notification(current_user, "auditó y realizó")
              flash[:success] = 'El recibo se ha auditado y realizado correctamente'
            else
              @external_order.create_notification(current_user, "auditó")
              flash[:success] = 'El recibo se ha auditado correctamente'
            end
          elsif @external_order.solicitud_abastecimiento?
            if sending?
              if @external_order.provider_sector == current_user.sector
                @external_order.send_order(current_user)
                @external_order.create_notification(current_user, "auditó y envió")
                flash[:success] = 'La solicitud de abastecimiento se ha auditado y aprovisionado correctamente'
              else
                @external_order.send_request_of(current_user)
                @external_order.create_notification(current_user, "auditó y envió")
                flash[:success] = 'La solicitud de abastecimiento se ha auditado y enviado correctamente'
              end
            else
              if @external_order.solicitud_enviada?
                @external_order.proveedor_auditoria!
                @external_order.create_notification(current_user, "auditó")
                flash[:success] = 'La solicitud de abastecimiento se ha auditado correctamente'
              elsif @external_order.proveedor_auditoria?
                @external_order.accept_order(current_user)
                @external_order.create_notification(current_user, "auditó y aceptó")
                flash[:success] = 'La solicitud de abastecimiento se ha auditado y aceptado correctamente'
              else
                @external_order.create_notification(current_user, "auditó")
                flash[:success] = 'La solicitud de abastecimiento se ha auditado correctamente'
              end
            end
          end   
        rescue ArgumentError => e
          flash[:alert] = e.message
          if @external_order.despacho?
            @order_type = 'despacho'
            @sectors = Sector.with_establishment_id(@external_order.applicant_sector.establishment_id)
            format.html { render :edit }
          elsif @external_order.recibo?
            @order_type = 'recibo'
            @sectors = Sector.with_establishment_id(@external_order.provider_sector.establishment_id)
            format.html { render :edit_receipt }
          elsif @external_order.solicitud_abastecimiento? && @external_order.provider_sector == current_user.sector
            @order_type = 'despacho'
            format.html { render :edit }
          elsif @external_order.solicitud_abastecimiento?
            @sectors = Sector.with_establishment_id(@external_order.provider_sector.establishment_id)
            @order_type = 'solicitud_abastecimiento'
            format.html { render :edit_applicant }
          end
        else
          format.html { redirect_to @external_order }
        end
      else
        if @external_order.despacho?
          @order_type = 'despacho'
          @sectors = Sector.with_establishment_id(@external_order.applicant_sector.establishment_id)
          flash[:error] = "El despacho no se ha podido auditar."
          format.html { render :edit }
        elsif @external_order.recibo?
          @order_type = 'recibo'
          @sectors = Sector.with_establishment_id(@external_order.provider_sector.establishment_id)
          flash[:error] = "El recibo no se ha podido auditar."
          format.html { render :edit_receipt }
        elsif @external_order.solicitud_abastecimiento?
          @sectors = Sector.with_establishment_id(@external_order.provider_sector.establishment_id)
          @order_type = 'solicitud_abastecimiento'
          flash[:error] = "La solicitud de abastecimiento no se ha podido auditar."
          format.html { render :edit_applicant }
        end
      end
    end
  end

  # GET /external_orders/1/send_provider
  def send_provider
    authorize @external_order
    @users = User.with_sector_id(current_user.sector_id)
    respond_to do |format|
      format.js
    end
  end

  # GET /external_orders/1/accept_provider
  def accept_provider
    authorize @external_order
    respond_to do |format|
      format.js
    end
  end

  # GET /external_orders/1/accept_provider_confirm
  def accept_provider_confirm
    respond_to do |format|
      format.js
    end
  end

  # GET /external_orders/1/receive_order
  def receive_order
    authorize @external_order
    respond_to do |format|
      begin
        if @external_order.recibo?
          @external_order.receive_remit(current_user)
          @external_order.create_notification(current_user, "realizó")
          flash[:success] = 'El recibo se ha realizado correctamente'
        elsif @external_order.despacho?
          @external_order.receive_order(current_user)
          @external_order.create_notification(current_user, "recibió")
          flash[:success] = 'El despacho se ha recibido correctamente'
        elsif @external_order.solicitud_abastecimiento?
          @external_order.receive_order(current_user)
          @external_order.create_notification(current_user, "recibió")
          flash[:success] = 'El pedido soliciado se ha recibido correctamente'
        end
      rescue ArgumentError => e
        flash[:error] = e.message
      end 
      format.html { redirect_to @external_order }
    end
  end

  # GET /external_orders/1/receive_order_confirm
  def receive_order_confirm
    respond_to do |format|
      format.js
    end
  end

  def return_status
    authorize @external_order
    respond_to do |format|
      begin
        @external_order.return_status
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

  def generate_order_report(external_order)
    report = Thinreports::Report.new layout: File.join(Rails.root, 'app', 'reports', 'external_order', 'first_page_despacho.tlf')

    report.use_layout File.join(Rails.root, 'app', 'reports', 'external_order', 'first_page_despacho.tlf'), :default => true
    report.use_layout File.join(Rails.root, 'app', 'reports', 'external_order', 'other_page_despacho.tlf'), id: :other_page
    
    external_order.quantity_ord_supply_lots.joins(:supply).order("name").each do |qosl|
      if report.page_count == 1 && report.list.overflow?
        report.start_new_page layout: :other_page do |page|
        end
      end
      
      report.list do |list|
        list.add_row do |row|
          row.values  supply_code: qosl.supply_id,
                      supply_name: qosl.supply.name,
                      requested_quantity: qosl.requested_quantity.to_s+" "+qosl.unity.pluralize(qosl.requested_quantity),
                      delivered_quantity: qosl.delivered_quantity.to_s+" "+qosl.unity.pluralize(qosl.delivered_quantity),
                      lot: qosl.sector_supply_lot_lot_code,
                      laboratory: qosl.sector_supply_lot_laboratory_name,
                      expiry_date: qosl.sector_supply_lot_expiry_date, 
                      applicant_obs: qosl.provider_observation
        end

        report.list.on_page_footer_insert do |footer|
          footer.item(:total_supplies).value(external_order.quantity_ord_supply_lots.count)
          footer.item(:total_requested).value(external_order.quantity_ord_supply_lots.sum(&:requested_quantity))
          footer.item(:total_delivered).value(external_order.quantity_ord_supply_lots.sum(&:delivered_quantity))
          footer.item(:total_obs).value(external_order.quantity_ord_supply_lots.where.not(provider_observation: [nil, ""]).count())
        end
      end
      
      if report.page_count == 1
        report.page[:applicant_sector] = external_order.applicant_sector.name
        report.page[:applicant_establishment] = external_order.applicant_establishment.name
        report.page[:provider_sector] = external_order.provider_sector.name
        report.page[:provider_establishment] = external_order.provider_establishment.name
        report.page[:observations] = external_order.observation
      end
    end
    

    report.pages.each do |page|
      page[:title] = 'Reporte de '+external_order.order_type.humanize.underscore
      page[:remit_code] = external_order.remit_code
      page[:requested_date] = external_order.requested_date.strftime('%d/%m/%YY')
      page[:page_count] = report.page_count
      page[:sector] = current_user.sector_name
      page[:establishment] = current_user.establishment_name
    end

    report.generate
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
      params.require(:external_order).permit(:applicant_sector_id, :provider_sector_id,
      :requested_date, :sector_id, :observation, :sent_by_id, :remit_code, :order_type,
        quantity_ord_supply_lots_attributes: [:id, :supply_lot_id, :supply_id, :sector_supply_lot_id,
          :requested_quantity, :delivered_quantity, :lot_code, :laboratory_id, :expiry_date, 
          :applicant_observation, :provider_observation, :_destroy
        ]
      )
    end

    def accepting?
      submit = params[:commit]
      return submit == "Auditar y aceptar" || submit == "Aceptar"
    end

    def receiving?
      submit = params[:commit]
      return submit == "Recibir" || submit == "Auditar y recibir"
    end

    def sending?
      submit = params[:commit]
      return submit == "Enviar" || submit == "Auditar y enviar"
    end

    def save_my_previous_url
      # session[:previous_url] is a Rails built-in variable to save last url.
      session[:my_previous_url] = URI(request.referer || '').path
    end
end
