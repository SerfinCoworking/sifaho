class Establishments::ExternalOrders::ApplicantsController < Establishments::ExternalOrders::ExternalOrdersController
  
  before_action :set_applicant_order, only: [
    :edit,
    :update,
    :dispatch_order,
    :rollback_order,
    :accept_provider,
    :receive_order
  ]

  # GET /external_orders/applicants
  # GET /external_orders/applicants.json
  def index
    policy(:external_order_applicant).index?
    @filterrific = initialize_filterrific(
      ExternalOrder.applicant(current_user.sector),
      params[:filterrific],
      select_options: {
        sorted_by: ExternalOrder.options_for_sorted_by,
        with_status: ExternalOrder.options_for_status
      },
      persistence_id: false
    ) or return
    @applicant_orders = @filterrific.find.paginate(page: params[:page], per_page: 15)
  end

  # GET /external_orders/applicant
  def new
    authorize :external_order_applicant
    begin
      new_from_template(params[:template], 'solicitud')
    rescue
      flash[:error] = 'No se ha encontrado la plantilla' if params[:template].present?
      @external_order = ExternalOrder.new
      @external_order.order_type = 'solicitud'
      @sectors = []
      @external_order.order_products.build
    end
  end

  # GET /external_orders/applicant/1/edit
  def edit
    policy(:external_order_applicant).edit?(@external_order)
    @external_order.order_products || @external_order.order_products.build
    @sectors = @external_order.provider_sector.present? ? @external_order.provider_establishment.sectors : []
  end

  # POST /external_orders/applicants
  # POST /external_orders/applicants.json
  def create
    policy(:external_order_applicant).create?
    @external_order = ExternalOrder.new(external_order_params)
    @external_order.requested_date = DateTime.now
    @external_order.applicant_sector = current_user.sector
    @external_order.order_type = "solicitud"
    @external_order.status = sending? ? "solicitud_enviada" : "solicitud_auditoria"

    respond_to do |format|
      begin
        @external_order.save!
        message = sending? ? "La solicitud de abastecimiento se ha creado y enviado correctamente." : "La solicitud de abastecimiento se ha creado y se encuentra en auditoría."
        notification_type = sending? ? "creó y envió" : "creó y auditó"

        @external_order.create_notification(current_user, notification_type)

        format.html { redirect_to external_orders_applicant_url(@external_order), notice: message }
      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @order_products = @external_order.order_products.present? ? @external_order.order_products : @external_order.order_products.build
        @sectors = @external_order.provider_sector.present? ? @external_order.provider_establishment.sectors : []
        format.html { render :new_applicant }
      end
    end
  end

  # PATCH /external_orders/applicants/1
  def update
    policy(:external_order_applicant).update?(@external_order)
    @external_order.status = sending? ? "solicitud_enviada" : "solicitud_auditoria"

    respond_to do |format|
      begin
        @external_order.update(external_order_params)
        @external_order.save!

        message = sending? ? "La solicitud se ha auditado y enviado correctamente." : "La solicitud se ha auditado y se encuentra en auditoria."
        notification_type = sending? ? "auditó y envió" : "auditó"

        @external_order.create_notification(current_user, notification_type)

        format.html { redirect_to external_orders_applicant_url(@external_order), notice: message }
      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @order_products = @external_order.order_products.present? ? @external_order.order_products : @external_order.order_products.build
        @sectors = @external_order.provider_sector.present? ? @external_order.provider_establishment.sectors : []
        format.html { render :edit_applicant }
      end
    end
  end

  # GET /external_orders/applicants/1/dispatch_order
  def dispatch_order
    policy(:external_order_applicant).can_send?(@external_order)
    @external_order.send_request_by(current_user)
    respond_to do |format|
      message = 'La solicitud se ha enviado correctamente.'
      format.html { redirect_to external_orders_applicant_url(@external_order), notice: message }
    end
  end

  # GET /external_orders/applicants/1/rollback_order
  def rollback_order
    policy(:external_order_applicant).rollback_order?(@external_order)
    respond_to do |format|
      begin
        @external_order.return_applicant_status_by(current_user)
        flash[:notice] = 'La solicitud se ha retornado a un estado anterior.'
      rescue ArgumentError => e
        flash[:alert] = e.message
      end
      format.html { redirect_to external_orders_applicant_url(@external_order) }
    end
  end

  # GET /external_orders/applicants/1/receive_order
  def receive_order
    policy(:external_order_applicant).receive_order?(@external_order)
    respond_to do |format|
      begin
        unless @external_order.provision_en_camino?; raise ArgumentError, 'La provisión aún no está en camino.'; end
        @external_order.receive_order_by(current_user)
        flash[:success] = "La #{@external_order.order_type} se ha recibido correctamente"
      rescue ArgumentError => e
        flash[:error] = e.message
      end
      format.html { redirect_to external_orders_applicant_url(@external_order) }
    end
  end
  
  # DELETE /external_orders/applicants/1
  def destroy
    policy(:external_order_applicant).destroy?(@external_order)
    super destroy
  end

  private

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
      order_products_attributes: [
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

    def new_from_template(template_id, order_type)
      # Buscamos el template
      @external_order_template = ExternalOrderTemplate.find_by(id: template_id, order_type: order_type)
      @external_order = ExternalOrder.new
      @external_order.order_type = @external_order_template.order_type
      
      if @external_order.provision?
        @external_order.applicant_sector = @external_order_template.destination_sector
      else
        @external_order.provider_sector = @external_order_template.destination_sector
      end
      
      # Seteamos los productos a la orden
      @external_order_template.external_order_product_templates.joins(:product).order("name").each do |iots|
        @external_order.order_products.build(product_id: iots.product_id)
      end
      # Establecemos la opciones del selector de sector
      @sectors = Sector
        .select(:id, :name)
        .with_establishment_id(@external_order_template.destination_establishment_id)
        .where.not(id: current_user.sector_id)
    end

    def sending?
      return params[:commit] == "sending"
    end
end
