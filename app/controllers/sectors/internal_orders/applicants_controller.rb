class Sectors::InternalOrders::ApplicantsController < Sectors::InternalOrders::InternalOrderController

  before_action :set_internal_order, only: %i[show destroy edit update receive_confirm receive
    rollback_order dispatch_order]
  # GET /internal_orders
  # GET /internal_orders.json
  def index
    # authorize InternalOrder
    @filterrific = initialize_filterrific(
      InternalOrder.applicant(current_user.sector),
      params[:filterrific],
      select_options: {
        with_status: InternalOrder.options_for_status
      },
      persistence_id: false,
    ) or return
    @applicant_orders = @filterrific.find.page(params[:page]).per_page(15)
  end

  # GET /internal_orders/new_applicant
  def new
    # authorize InternalOrder
    begin
      new_from_template(params[:template], 'solicitud')
    rescue
      flash[:error] = 'No se ha encontrado la plantilla' if params[:template].present?
      @internal_order = InternalOrder.new
      @internal_order.order_type = 'solicitud'
      @sectors = Sector.select(:id, :name)
                       .with_establishment_id(current_user.sector.establishment_id)
                       .where.not(id: current_user.sector_id).as_json
      @internal_order.order_products.build
    end
  end

  # GET /external_orders/1/edit_receipt
  def edit
    # authorize @internal_order
    @sectors = Sector.select(:id, :name)
                     .with_establishment_id(current_user.sector.establishment_id)
                     .where.not(id: current_user.sector_id).as_json
  end

  # POST /internal_orders
  # POST /internal_orders.json
  def create
    @internal_order = InternalOrder.new(internal_order_params)
    # authorize @internal_order
    @internal_order.created_by = current_user
    @internal_order.audited_by = current_user
    @internal_order.requested_date = DateTime.now
    @internal_order.applicant_sector = current_user.sector
    @internal_order.order_type = 'solicitud'

    respond_to do |format|
      begin
        @internal_order.save!

        if sending?
          @internal_order.solicitud_enviada!
          @internal_order.create_notification(current_user, 'creó y envió')
          message = 'La solicitud se ha auditado y enviado correctamente.'
        else
          @internal_order.solicitud_auditoria!
          @internal_order.create_notification(current_user, 'creó y auditó')
          message = 'La solicitud se ha creado y se encuentra en auditoria.'
        end

        format.html { redirect_to internal_orders_applicant_url(@internal_order), notice: message }
      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @sectors = Sector.select(:id, :name)
                         .with_establishment_id(current_user.sector.establishment_id)
                         .where.not(id: current_user.sector_id).as_json
        @order_products = @internal_order.order_products.present? ? @internal_order.order_products : @internal_order.order_products.build
        format.html { render :new }
      end
    end
  end

  # PATCH /internal_orders
  # PATCH /internal_orders.json
  def update
    # authorize @internal_order
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

        format.html { redirect_to internal_orders_applicant_url(@internal_order), notice: message }
      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @sectors = Sector
          .select(:id, :name)
          .with_establishment_id(current_user.sector.establishment_id)
          .where.not(id: current_user.sector_id).as_json
          @order_products = @internal_order.order_products.present? ? @internal_order.order_products : @internal_order.order_products.build
        format.html { render :edit }
      end
    end
  end

  def rollback_order
    # authorize @internal_order
    respond_to do |format|
      begin
        @internal_order.return_applicant_status_by(current_user)
        flash[:notice] = 'La solicitud se ha retornado a un estado anterior.'
      rescue ArgumentError => e
        flash[:alert] = e.message
      end
      format.html { redirect_to internal_orders_applicant_url(@internal_order) }
    end
  end

  # GET /external_orders/applicants/1/dispatch_order
  def dispatch_order
    # authorize @internal_order
    @internal_order.send_request_by(current_user)
    respond_to do |format|
      format.html { redirect_to internal_orders_applicant_url(@internal_order), notice: 'La solicitud se ha enviado correctamente.' }
    end
  end


  # # GET /internal_orders/1/receive_applicant
  # def receive_applicant
  #   # authorize @internal_order
  #   respond_to do |format|
  #     begin
  #       unless @internal_order.provision_en_camino?; raise ArgumentError, 'La provisión aún no está en camino.'; end
  #       @internal_order.receive_order_by(current_user)
  #       flash[:success] = 'La '+@internal_order.order_type+' se ha recibido correctamente'
  #     rescue ArgumentError => e
  #       flash[:error] = e.message
  #     end
  #     format.html { redirect_to @internal_order }
  #   end
  # end
end
