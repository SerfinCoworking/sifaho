class InternalOrdersController < ApplicationController
  before_action :set_internal_order, only: [:show, :edit_provider, :update, :destroy, :delete,
  :edit_applicant, :update_applicant, :update_provider, :send_provider, :receive_applicant_confirm, :receive_applicant, 
  :return_provider_status, :return_applicant_status, :send_applicant, :nullify, :nullify_confirm ]

  def statistics
    @internal_providers = InternalOrder.provider(current_user.sector)
    @internal_applicants = InternalOrder.applicant(current_user.sector)
  end

  # GET /internal_orders
  # GET /internal_orders.json
  def provider_index
    authorize InternalOrder
    @filterrific = initialize_filterrific(
      InternalOrder.provider(current_user.sector).without_status(0),
      params[:filterrific],
      select_options: {
        with_status: InternalOrder.options_for_status
      },
      persistence_id: false,
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
    @internal_order.internal_order_products.build
  end

  # GET /internal_orders/new_applicant
  def new_applicant
    authorize InternalOrder
    @internal_order = InternalOrder.new
    @provider_sectors = Sector
      .select(:id, :name)
      .with_establishment_id(current_user.sector.establishment_id)
      .where.not(id: current_user.sector_id).as_json
    @internal_order.internal_order_products.build
  end

  # GET /internal_orders/1/edit
  def edit_provider
    authorize @internal_order
    @applicant_sectors = Sector
    .select(:id, :name)
    .with_establishment_id(current_user.sector.establishment_id)
    .where.not(id: current_user.sector_id).as_json
    @internal_order.internal_order_products.joins(:product).order("name")
  end

  # GET /external_orders/1/edit_receipt
  def edit_applicant
    authorize @internal_order
    @provider_sectors = Sector
      .select(:id, :name)
      .with_establishment_id(current_user.sector.establishment_id)
      .where.not(id: current_user.sector_id).as_json
    @internal_order.internal_order_products.joins(:product).order("name")
  end

  # POST /internal_orders
  # POST /internal_orders.json
  def create_applicant
    @internal_order = InternalOrder.new(internal_order_params)
    authorize @internal_order
    @internal_order.created_by = current_user
    @internal_order.audited_by = current_user
    @internal_order.requested_date = DateTime.now
    @internal_order.applicant_sector = current_user.sector
    @internal_order.order_type = "solicitud"

    respond_to do |format|
      begin
        @internal_order.save!

        if sending?
          @internal_order.solicitud_enviada!
          @internal_order.create_notification(current_user, "creó y envió")
          message = "La solicitud se ha auditado y enviado correctamente."
        else
          @internal_order.solicitud_auditoria!
          @internal_order.create_notification(current_user, "creó y auditó")
          message = "La solicitud se ha creado y se encuentra en auditoria."
        end

        format.html { redirect_to @internal_order }
      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @provider_sectors = Sector
          .select(:id, :name)
          .with_establishment_id(current_user.sector.establishment_id)
          .where.not(id: current_user.sector_id).as_json
          @internal_order_products = @internal_order.internal_order_products.present? ? @internal_order.internal_order_products : @internal_order.internal_order_products.build
        format.html { render :new_applicant }
      end
    end
  end

  def create_provider 
    @internal_order = InternalOrder.new(internal_order_params)
    authorize @internal_order
    @internal_order.created_by = current_user
    @internal_order.audited_by = current_user
    @internal_order.requested_date = DateTime.now
    @internal_order.provider_sector = current_user.sector
    @internal_order.order_type = "provision"
    @internal_order.status = sending? ? "provision_en_camino" : "proveedor_auditoria"

    respond_to do |format|
      begin
        @internal_order.save!
        
        if sending?; @internal_order.send_order_by(current_user); end

        message = sending? ? "La provisión interna de "+@internal_order.applicant_sector.name+" se ha auditado y enviado correctamente." :message = "La provisión interna de "+@internal_order.applicant_sector.name+" se ha auditado correctamente."
        format.html { redirect_to @internal_order, notice: message }
      rescue ArgumentError => e
        # si fallo la validacion de stock debemos modificar el estado a proveedor_auditoria
        @internal_order.proveedor_auditoria!
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure  
        @applicant_sectors = Sector
          .select(:id, :name)
          .with_establishment_id(current_user.sector.establishment_id)
          .where.not(id: current_user.sector_id).as_json
        @internal_order_products = @internal_order.internal_order_products.present? ? @internal_order.internal_order_products : @internal_order.internal_order_products.build
        format.html { render :new_provider }
      end
    end
  end
  
  # PATCH /internal_orders
  # PATCH /internal_orders.json
  def update_applicant
    authorize @internal_order
    @internal_order.audited_by = current_user

    respond_to do |format|
      begin
        @internal_order.update(internal_order_params)
        @internal_order.save!

        if sending?
          @internal_order.solicitud_enviada!
          @internal_order.create_notification(current_user, "creó y envió")
          message = "La solicitud se ha auditado y enviado correctamente."
        else
          @internal_order.solicitud_auditoria!
          @internal_order.create_notification(current_user, "creó y auditó")
          message = "La solicitud se ha creado y se encuentra en auditoria."
        end

        format.html { redirect_to @internal_order }
      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @provider_sectors = Sector
          .select(:id, :name)
          .with_establishment_id(current_user.sector.establishment_id)
          .where.not(id: current_user.sector_id).as_json
          @internal_order_products = @internal_order.internal_order_products.present? ? @internal_order.internal_order_products : @internal_order.internal_order_products.build
        format.html { render :new_applicant }
      end
    end
  end
  
  # PATCH /internal_orders
  # PATCH /internal_orders.json
  def update_provider
    authorize @internal_order
    previous_status = @internal_order.status
    @internal_order.audited_by = current_user
    @internal_order.status = sending? ? "provision_en_camino" : 'proveedor_auditoria'
        
    respond_to do |format|
      begin
        @internal_order.update!(internal_order_params)

        if sending?; @internal_order.send_order_by(current_user); end
        
        message = sending? ? 'La provision se ha enviado correctamente.' : "La solicitud se ha editado y se encuentra en auditoria."

        format.html { redirect_to @internal_order, notice: message }
      rescue ArgumentError => e
        # si fallo la validación de stock, debemos volver atras el estado de la orden
        @internal_order.status = previous_status
        @internal_order.save!
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @applicant_sectors = Sector
          .select(:id, :name)
          .with_establishment_id(current_user.sector.establishment_id)
          .where.not(id: current_user.sector_id).as_json
          @internal_order_products = @internal_order.internal_order_products.present? ? @internal_order.internal_order_products : @internal_order.internal_order_products.build
        format.html { render :edit_provider }
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

    respond_to do |format|
      begin
        @internal_order.status = "provision_en_camino"
        @internal_order.save!

        @internal_order.send_order_by(current_user);
        
        message = 'La provision se ha enviado correctamente.'

        format.html { redirect_to @internal_order, notice: message }
      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @applicant_sectors = Sector
          .select(:id, :name)
          .with_establishment_id(current_user.sector.establishment_id)
          .where.not(id: current_user.sector_id).as_json
          @internal_order_products = @internal_order.internal_order_products.present? ? @internal_order.internal_order_products : @internal_order.internal_order_products.build
        format.html { render :edit_provider }
      end
    end    
  end

  # GET /internal_orders/1/send_applicant
  def send_applicant
    authorize @internal_order
    @internal_order.send_request_by(current_user)
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
        unless @internal_order.provision_en_camino?; raise ArgumentError, 'La provisión aún no está en camino.'; end
        @internal_order.receive_order_by(current_user)
        flash[:success] = 'La '+@internal_order.order_type+' se ha recibido correctamente'
      rescue ArgumentError => e
        flash[:error] = e.message
      end
      format.html { redirect_to @internal_order }
    end
  end

  def return_provider_status
    authorize @internal_order
    respond_to do |format|
      begin
        @internal_order.return_provider_status_by(current_user)
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
        @internal_order.return_applicant_status_by(current_user)
        flash[:notice] = 'La solicitud se ha retornado a un estado anterior.'
      rescue ArgumentError => e
        flash[:alert] = e.message
      end
      format.html { redirect_to @internal_order }
    end
  end

  # def generate_report
  #   authorize InternalOrder
  #   respond_to do |format|
  #     if params[:internal_order][:since_date].present? && params[:internal_order][:to_date].present?
  #       @since_date = DateTime.parse(params[:internal_order][:since_date])
  #       @to_date = DateTime.parse(params[:internal_order][:to_date])
  #       @filtered_orders =  InternalOrder.provider(current_user.sector).requested_date_since(@since_date).requested_date_to(@to_date).without_status(0).joins(:applicant_sector).group('sectors.name').count
  #       flash.now[:success] = "Reporte generado."
  #       format.html { render :generate_report}
  #     else
  #       @internal_order = InternalOrder.new
  #       flash.now[:error] = "Verifique los campos."
  #       format.html { render :new_report }
  #     end  
  #   end
  # end

  # def generate_internal_order_report(internal_order)
  #   report = Thinreports::Report.new layout: File.join(Rails.root, 'app', 'reports', 'internal_order', 'first_page_order.tlf')

  #   report.use_layout File.join(Rails.root, 'app', 'reports', 'internal_order', 'first_page_order.tlf'), :default => true
  #   report.use_layout File.join(Rails.root, 'app', 'reports', 'internal_order', 'other_page_order.tlf'), id: :other_page
    
  #   internal_order.quantity_ord_supply_lots.joins(:supply).order("name").each do |qosl|
  #     if report.page_count == 1 && report.list.overflow?
  #       report.start_new_page layout: :other_page do |page|
  #       end
  #     end
      
  #     report.list do |list|
  #       list.add_row do |row|
  #         row.values  supply_code: qosl.supply_id,
  #                     supply_name: qosl.supply.name,
  #                     requested_quantity: qosl.requested_quantity.to_s+" "+qosl.unity.pluralize(qosl.requested_quantity),
  #                     delivered_quantity: qosl.delivered_quantity.to_s+" "+qosl.unity.pluralize(qosl.delivered_quantity),
  #                     lot: qosl.sector_supply_lot_lot_code,
  #                     laboratory: qosl.sector_supply_lot_laboratory_name,
  #                     expiry_date: qosl.sector_supply_lot_expiry_date, 
  #                     applicant_obs: internal_order.provision? ? qosl.provider_observation : qosl.applicant_observation
  #       end

  #       report.list.on_page_footer_insert do |footer|
  #         footer.item(:total_supplies).value(internal_order.quantity_ord_supply_lots.count)
  #         footer.item(:total_requested).value(internal_order.quantity_ord_supply_lots.sum(&:requested_quantity))
  #         footer.item(:total_delivered).value(internal_order.quantity_ord_supply_lots.sum(&:delivered_quantity))
  #         if internal_order.solicitud?
  #           footer.item(:total_obs).value(internal_order.quantity_ord_supply_lots.where.not(provider_observation: [nil, ""]).count())
  #         else
  #           footer.item(:total_obs).value(internal_order.quantity_ord_supply_lots.where.not(applicant_observation: [nil, ""]).count())
  #         end
  #       end
  #     end

  #     if report.page_count == 1
  #       report.page[:applicant_sector] = internal_order.applicant_sector.name
  #       report.page[:provider_sector] = internal_order.provider_sector.name
  #       report.page[:observations] = internal_order.observation
  #     end
  #   end
    
  #   report.pages.each do |page|
  #     page[:title] = 'Reporte de '+internal_order.order_type.humanize.underscore
  #     page[:remit_code] = internal_order.remit_code
  #     page[:requested_date] = internal_order.requested_date.strftime('%d/%m/%YY')
  #     page[:page_count] = report.page_count
  #     page[:sector] = current_user.sector_name
  #     page[:establishment] = current_user.establishment_name
  #   end

  #   report.generate
  # end

  # anular orden
  # patch /internal_orders/1/nullify
  def nullify
    authorize @internal_order
    @internal_order.nullify_by(current_user)
    respond_to do |format|
      flash[:success] = "#{@internal_order.order_type.humanize} se ha anulado correctamente."
      format.html { redirect_to @internal_order }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_internal_order
    @internal_order = InternalOrder.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def internal_order_params
    params.require(:internal_order).permit(:applicant_sector_id, 
      :sent_by_id, 
      :order_type,
      :provider_sector_id, 
      :requested_date, 
      :date_received, 
      :observation, 
      :remit_code,
      internal_order_products_attributes: [
        :id, 
        :product_id, 
        :lot_stock_id,
        :request_quantity,
        :delivery_quantity,
        :applicant_observation,
        :provider_observation, 
        :_destroy,
        int_ord_prod_lot_stocks_attributes: [
          :id,
          :quantity,
          :lot_stock_id,
          :_destroy
        ]
      ]
    )
  end

  # Se verifica si el value del submit del form es para enviar
  def sending?
    return params[:commit] == "sending"
  end

  def applicant?
    submit = params[:commit]
    return submit == "Solicitante"
  end

  def provider?
    submit = params[:commit]
    return submit == "Proveedor"
  end

  # def generate_apply_report(orders)
  #   report = Thinreports::Report.new layout: File.join(Rails.root, 'app', 'reports', 'internal_order', 'i_o_list.tlf')

  #   orders.each do |order|
  #     report.list.add_row do |row|
  #       row.values  code: order.remit_code,
  #                   sector_name: order.provider_sector.name,
  #                   origin: order.order_type.underscore.humanize,
  #                   status: order.status.underscore.humanize,
  #                   supplies: order.quantity_ord_supply_lots.count,
  #                   movements: order.movements.count,
  #                   requested_date: order.requested_date.strftime("%d/%m/%Y"),
  #                   received_date: order.date_received.present? ? order.date_received.strftime("%d/%m/%Y") : '----'
  #     end
  #   end
  #   report.page[:page_count] = report.page_count
  #   report.page[:title] = 'Reporte recibos pedidos internos'

  #   report.generate
  # end
end