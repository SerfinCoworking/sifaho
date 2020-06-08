class InternalOrdersController < ApplicationController
  before_action :set_internal_order, only: [:show, :edit, :update, :destroy, :delete, 
  :edit_applicant, :send_provider, :receive_applicant_confirm, :receive_applicant, 
  :return_provider_status, :return_applicant_status, :send_applicant, :nullify, :nullify_confirm ]

  def statistics
    @internal_providers = InternalOrder.provider(current_user.sector)
    @internal_applicants = InternalOrder.applicant(current_user.sector)
  end

  # GET /internal_orders
  # GET /internal_orders.json
  def index
    authorize InternalOrder
    @filterrific = initialize_filterrific(
      InternalOrder.provider(current_user.sector).without_status(0),
      params[:filterrific],
      select_options: {
        with_status: InternalOrder.options_for_status
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'created_at_desc'},
      available_filters: [
        :search_code,
        :search_applicant,
        :with_order_type,
        :with_status,
        :requested_date_since,
        :requested_date_to,
        :date_received_since,
        :date_received_to,
        :sorted_by
      ],
    ) or return
    @internal_orders = @filterrific.find.page(params[:page]).per_page(15)
  end
  
  # GET /internal_orders
  # GET /internal_orders.json
  def applicant_index
    authorize InternalOrder
    @filterrific = initialize_filterrific(
      InternalOrder.applicant(current_user.sector),
      params[:filterrific],
      select_options: {
        with_status: InternalOrder.options_for_status
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'created_at_desc'},
      available_filters: [
        :search_code,
        :search_applicant,
        :search_provider,
        :with_order_type,
        :with_status,
        :requested_date_since,
        :requested_date_to,
        :date_received_since,
        :date_received_to,
        :sorted_by
      ],
    ) or return
    @applicant_orders = @filterrific.find.page(params[:page]).per_page(15)

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        send_data generate_apply_report(@applicant_orders),
          filename: 'pedidos_internos.pdf',
          type: 'application/pdf',
          disposition: 'inline'
      end
    end
  end

  # GET /internal_orders/1
  # GET /internal_orders/1.json
  def show
    authorize @internal_order

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        send_data generate_internal_order_report(@internal_order),
          filename: 'Pedido_interno_'+@internal_order.remit_code+'.pdf',
          type: 'application/pdf',
          disposition: 'inline'
      end
    end
  end

  # GET /internal_orders/new
  def new
    authorize InternalOrder
    @internal_order = InternalOrder.new
    @providers = User.where.not(sector: current_user.sector_id )
  end

  # GET /internal_orders/new
  def new_report
    authorize InternalOrder
    @internal_order = InternalOrder.new
  end

  # GET /internal_orders/new_deliver
  def new_provider
    authorize InternalOrder
    @internal_order = InternalOrder.new
    @order_type = 'provision'
    @applicant_sectors = Sector
      .select(:id, :name)
      .with_establishment_id(current_user.sector.establishment_id)
      .where.not(id: current_user.sector_id).as_json
    4.times { @internal_order.quantity_ord_supply_lots.build }
  end

  # GET /internal_orders/new_applicant
  def new_applicant
    authorize InternalOrder
    @internal_order = InternalOrder.new
    @order_type = 'solicitud'
    @provider_sectors = Sector
      .select(:id, :name)
      .with_establishment_id(current_user.sector.establishment_id)
      .where.not(id: current_user.sector_id).as_json
    4.times { @internal_order.quantity_ord_supply_lots.build }
  end

  # GET /internal_orders/1/edit
  def edit
    authorize @internal_order
    @order_type = 'provision'
    @applicant_sectors = Sector
    .select(:id, :name)
    .with_establishment_id(current_user.sector.establishment_id)
    .where.not(id: current_user.sector_id).as_json
    @internal_order.quantity_ord_supply_lots.joins(:supply).order("name")
  end

  # GET /external_orders/1/edit_receipt
  def edit_applicant
    authorize @internal_order
    @order_type = 'solicitud'
    @provider_sectors = Sector
      .select(:id, :name)
      .with_establishment_id(current_user.sector.establishment_id)
      .where.not(id: current_user.sector_id).as_json
    @internal_order.quantity_ord_supply_lots.joins(:supply).order("name")
  end

  # POST /internal_orders
  # POST /internal_orders.json
  def create
    @internal_order = InternalOrder.new(internal_order_params)
    authorize @internal_order
    @internal_order.created_by = current_user
    @internal_order.audited_by = current_user

    respond_to do |format|
      if @internal_order.save
        begin
          if @internal_order.provision?
            # Si se carga y provision el pedido
            if sending_by_provider?
              @internal_order.send_order_by(current_user)
              @internal_order.create_notification(current_user, "creó y envió")
              flash[:success] = "La provisión interna de "+@internal_order.applicant_sector.name+" se ha auditado y enviado correctamente."
            else
              @internal_order.proveedor_auditoria!
              @internal_order.create_notification(current_user, "creó y auditó")
              flash[:success] = "La provisión interna de "+@internal_order.applicant_sector.name+" se ha auditado correctamente."
            end
          elsif @internal_order.solicitud?
            if sending?
              @internal_order.solicitud_enviada!
              @internal_order.create_notification(current_user, "creó y envió")
              flash[:success] = "La solicitud se ha auditado y enviado correctamente."
            else
              @internal_order.solicitud_auditoria!
              @internal_order.create_notification(current_user, "creó y auditó")
              flash[:success] = "La solicitud se ha creado y se encuentra en auditoria."
            end
          end
        rescue ArgumentError => e
          flash[:alert] = e.message
          if @internal_order.provision?
            @order_type = 'provision'
            @applicant_sectors = Sector
              .select(:id, :name)
              .with_establishment_id(current_user.sector.establishment_id)
              .where.not(id: current_user.sector_id).as_json
            format.html { render :new_provider }
          elsif @internal_order.solicitud?
            @order_type = 'solicitud'
            @provider_sectors = Sector
              .select(:id, :name)
              .with_establishment_id(current_user.sector.establishment_id)
              .where.not(id: current_user.sector_id).as_json
            format.html { render :new_applicant }
          end
        else
          format.html { redirect_to @internal_order }
        end
      else
        flash[:error] = "La "+@internal_order.order_type+" no se ha podido crear."
        if @internal_order.provision?
          @order_type = 'provision'
          @applicant_sectors = Sector
            .select(:id, :name)
            .with_establishment_id(current_user.sector.establishment_id)
            .where.not(id: current_user.sector_id).as_json
          format.html { render :new_provider }
        elsif @internal_order.solicitud?
          @order_type = 'solicitud'
          @provider_sectors = Sector
            .select(:id, :name)
            .with_establishment_id(current_user.sector.establishment_id)
            .where.not(id: current_user.sector_id).as_json
          format.html { render :new_applicant }
        end
      end
    end
  end

  # PATCH/PUT /internal_orders/1
  # PATCH/PUT /internal_orders/1.json
  def update 
    authorize @internal_order
    audited_by = current_user
    respond_to do |format|
      if @internal_order.update(internal_order_params)
        begin
            if @internal_order.provision?
              if sending_by_provider?
                @internal_order.send_order_by(current_user)
                @internal_order.create_notification(current_user, "auditó y envió")
                flash[:success] = 'La provision se ha enviado correctamente.'
              else
                @internal_order.create_notification(current_user, "auditó")
                flash[:notice] = 'La provision se ha auditado correctamente.'
              end
            elsif @internal_order.solicitud?
              if sending?
                @internal_order.send_request_of(current_user)
                @internal_order.create_notification(current_user, "auditó y envió")
                flash[:success] = 'La solicitud se ha enviado correctamente.'
              elsif sending_by_provider?
                @internal_order.send_order_by(current_user)
                @internal_order.create_notification(current_user, "envió")
                flash[:success] = 'La solicitud se ha provisto correctamente.'
              elsif applicant?
                @internal_order.solicitud_auditoria!
                @internal_order.create_notification(current_user, "auditó")
                flash[:notice] = 'La solicitud se ha auditado correctamente.'
              elsif provider?
                @internal_order.proveedor_auditoria!
                @internal_order.create_notification(current_user, "auditó")
                flash[:notice] = 'La solicitud se ha auditado correctamente.'
              end
            end
          format.html { redirect_to @internal_order }
        rescue ArgumentError => e
          flash[:alert] = e.message
        end 
        format.html { redirect_to @internal_order }
      else
        flash[:error] = "La provision no se ha podido guardar."
        if @internal_order.is_provider?(current_user)
          @order_type = 'provision'
          @applicant_sectors = Sector
            .select(:id, :name)
            .with_establishment_id(current_user.sector.establishment_id)
            .where.not(id: current_user.sector_id).as_json          
          format.html { render :edit }
        elsif @internal_order.is_applicant?(current_user) 
          @order_type = 'solicitud'
          @provider_sectors = Sector
            .select(:id, :name)
            .with_establishment_id(current_user.sector.establishment_id)
            .where.not(id: current_user.sector_id).as_json
          format.html { render :edit_applicant }
        end
      end
    end
  end

  # DELETE /internal_orders/1
  # DELETE /internal_orders/1.json
  def destroy
    authorize @internal_order

    @internal_order.destroy
    respond_to do |format|
      @internal_order.create_notification(current_user, "envió a la papelera")
      flash.now[:success] = "El pedido interno de se ha enviado a la papelera correctamente."
      format.js
    end
  end

  # GET /internal_order/1/delete
  def delete
    authorize @internal_order
    respond_to do |format|
      format.js
    end
  end

  # GET /internal_order/1/send_provider
  def send_provider
    authorize @internal_order
    @users = User.with_sector_id(current_user.sector_id)
    respond_to do |format|
      format.js
    end
  end

  # GET /internal_orders/1/send_applicant
  def send_applicant
    authorize @internal_order
    @internal_order.solicitud_enviada!
    @internal_order.create_notification(current_user, "envió")
    respond_to do |format|
      flash[:success] = "La solicitud se ha enviado correctamente."
      format.html { redirect_to @internal_order }
    end
  end

  # GET /internal_orders/1/receive_applicant
  def receive_applicant
    authorize @internal_order
    respond_to do |format|
      begin
        @internal_order.received_by = current_user
        @internal_order.receive_order(current_user.sector)
        @internal_order.create_notification(current_user, "recibió")
        flash[:success] = 'La '+@internal_order.order_type+' se ha recibido correctamente'
      rescue ArgumentError => e
        flash[:error] = e.message
      end
      format.html { redirect_to @internal_order }
    end
  end

  # GET /internal_orders/1/receive_applicant_confirm
  def receive_applicant_confirm
    respond_to do |format|
      format.js
    end
  end

  def return_provider_status
    authorize @internal_order
    respond_to do |format|
      begin
        @internal_order.return_provider_status
        @internal_order.create_notification(current_user, "retornó a un estado anterior")
        flash[:notice] = 'La '+@internal_order.order_type+' se ha retornado a un estado anterior.'
      rescue ArgumentError => e
        flash[:alert] = e.message
      end
      format.html { redirect_to @internal_order }
    end
  end

  def return_applicant_status
    authorize @internal_order
    respond_to do |format|
      begin
        @internal_order.return_applicant_status
        @internal_order.create_notification(current_user, "retornó a un estado anterior")
        flash[:notice] = 'La solicitud se ha retornado a un estado anterior.'
      rescue ArgumentError => e
        flash[:alert] = e.message
      end
      format.html { redirect_to @internal_order }
    end
  end

  def generate_report
    authorize InternalOrder
    respond_to do |format|
      if params[:internal_order][:since_date].present? && params[:internal_order][:to_date].present?
        @since_date = DateTime.parse(params[:internal_order][:since_date])
        @to_date = DateTime.parse(params[:internal_order][:to_date])
        @filtered_orders =  InternalOrder.provider(current_user.sector).requested_date_since(@since_date).requested_date_to(@to_date).without_status(0).joins(:applicant_sector).group('sectors.name').count
        flash.now[:success] = "Reporte generado."
        format.html { render :generate_report}
      else
        @internal_order = InternalOrder.new
        flash.now[:error] = "Verifique los campos."
        format.html { render :new_report }
      end  
    end
  end

  def generate_internal_order_report(internal_order)
    report = Thinreports::Report.new layout: File.join(Rails.root, 'app', 'reports', 'internal_order', 'first_page_order.tlf')

    report.use_layout File.join(Rails.root, 'app', 'reports', 'internal_order', 'first_page_order.tlf'), :default => true
    report.use_layout File.join(Rails.root, 'app', 'reports', 'internal_order', 'other_page_order.tlf'), id: :other_page
    
    internal_order.quantity_ord_supply_lots.joins(:supply).order("name").each do |qosl|
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
                      applicant_obs: internal_order.provision? ? qosl.provider_observation : qosl.applicant_observation
        end

        report.list.on_page_footer_insert do |footer|
          footer.item(:total_supplies).value(internal_order.quantity_ord_supply_lots.count)
          footer.item(:total_requested).value(internal_order.quantity_ord_supply_lots.sum(&:requested_quantity))
          footer.item(:total_delivered).value(internal_order.quantity_ord_supply_lots.sum(&:delivered_quantity))
          if internal_order.solicitud?
            footer.item(:total_obs).value(internal_order.quantity_ord_supply_lots.where.not(provider_observation: [nil, ""]).count())
          else
            footer.item(:total_obs).value(internal_order.quantity_ord_supply_lots.where.not(applicant_observation: [nil, ""]).count())
          end
        end
      end

      if report.page_count == 1
        report.page[:applicant_sector] = internal_order.applicant_sector.name
        report.page[:provider_sector] = internal_order.provider_sector.name
        report.page[:observations] = internal_order.observation
      end
    end
    
    report.pages.each do |page|
      page[:title] = 'Reporte de '+internal_order.order_type.humanize.underscore
      page[:remit_code] = internal_order.remit_code
      page[:requested_date] = internal_order.requested_date.strftime('%d/%m/%YY')
      page[:page_count] = report.page_count
      page[:sector] = current_user.sector_name
      page[:establishment] = current_user.establishment_name
    end

    report.generate
  end

  # GET /internal_orders/1/nullify
  def nullify
    authorize @internal_order
    respond_to do |format|
      format.js
    end
  end

  # patch /internal_orders/1/nullify
  def nullify_confirm
    authorize @internal_order
    @internal_order.observation= "el usuario: ' #{current_user.username} ' anulo esta #{@internal_order.order_type} "
    @internal_order.rejected_by_id= current_user.id
    @internal_order.anulada!
    @internal_order.create_notification(current_user, "Anulo")
    flash[:success] = "#{@internal_order.order_type} se ha anulado correctamente."
    redirect_to internal_orders_path
  end
  private

  # Use callbacks to share common setup or constraints between actions.
  def set_internal_order
    @internal_order = InternalOrder.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def internal_order_params
    params.require(:internal_order).permit(:applicant_sector_id, :sent_by_id, :order_type,
      :provider_sector_id, :requested_date, :date_received, :observation, :remit_code,
      quantity_ord_supply_lots_attributes: [:id, :supply_id, :sector_supply_lot_id,
        :requested_quantity, :delivered_quantity, :observation, :applicant_observation,
        :provider_observation, :_destroy]
      )
  end

  # Se verifica si el value del submit del form es para enviar
  def sending?
    submit = params[:commit]
    return submit == "Auditar y enviar" || submit == "Enviar"
  end

  def sending_by_provider?
    submit = params[:commit]
    return submit == "Enviar proveedor"
  end

  def applicant?
    submit = params[:commit]
    return submit == "Solicitante"
  end

  def provider?
    submit = params[:commit]
    return submit == "Proveedor"
  end

  def generate_apply_report(orders)
    report = Thinreports::Report.new layout: File.join(Rails.root, 'app', 'reports', 'internal_order', 'i_o_list.tlf')

    orders.each do |order|
      report.list.add_row do |row|
        row.values  code: order.remit_code,
                    sector_name: order.provider_sector.name,
                    origin: order.order_type.underscore.humanize,
                    status: order.status.underscore.humanize,
                    supplies: order.quantity_ord_supply_lots.count,
                    movements: order.movements.count,
                    requested_date: order.requested_date.strftime("%d/%m/%Y"),
                    received_date: order.date_received.present? ? order.date_received.strftime("%d/%m/%Y") : '----'
      end
    end
    report.page[:page_count] = report.page_count
    report.page[:title] = 'Reporte recibos pedidos internos'

    report.generate
  end
end