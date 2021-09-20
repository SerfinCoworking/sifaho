class Establishments::ExternalOrders::ApplicantsController < Establishments::ExternalOrders::ExternalOrdersController
  before_action :set_external_order, only: %i[show edit update dispatch_order rollback_order accept_provider 
                                              receive_order destroy edit_products save_product]
  before_action :set_last_requests, only: %i[new edit create update]

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
    flash[:error] = 'No se ha encontrado la plantilla' if params[:template].present?
    @external_order = ExternalOrder.new
    @external_order.order_type = 'solicitud'
    @sectors = []
    @external_order.order_products.build
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
    @external_order.order_type = 'solicitud'
    @external_order.status = 'solicitud_auditoria'

    respond_to do |format|
      begin
        @external_order.save!
        message = 'La solicitud de abastecimiento se ha creado y se encuentra en auditoría.'
        notification_type = 'creó y auditó'

        @external_order.create_notification(current_user, notification_type)

        format.html { redirect_to edit_products_external_orders_applicant_url(@external_order), notice: message }
      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @order_products = @external_order.order_products.present? ? @external_order.order_products : @external_order.order_products.build
        @sectors = @external_order.provider_sector.present? ? @external_order.provider_establishment.sectors : []
        format.html { render :new }
      end
    end
  end

  def edit_products
    if params[:template].present?
      new_from_template(params[:template], 'solicitud') 
    else
      @external_order.order_products.build
    end
  end

  # PATCH /external_orders/applicants/1
  def update
    policy(:external_order_applicant).update?(@external_order)
    @external_order.status = 'solicitud_auditoria'

    respond_to do |format|
      begin
        @external_order.update(external_order_params)
        @external_order.save!

        message = 'La solicitud se ha auditado y se encuentra en auditoria.'
        notification_type = 'auditó'

        @external_order.create_notification(current_user, notification_type)

        format.html { redirect_to external_orders_applicant_url(@external_order), notice: message }
      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @order_products = @external_order.order_products.present? ? @external_order.order_products : @external_order.order_products.build
        @sectors = @external_order.provider_sector.present? ? @external_order.provider_establishment.sectors : []
        format.html { render :edit }
      end
    end
  end

  # GET /external_orders/applicants/1/dispatch_order
  def dispatch_order
    policy(:external_order_applicant).can_send?(@external_order)
    respond_to do |format|
      begin
        @external_order.send_request_by(current_user)
        format.html { redirect_to external_orders_applicant_url(@external_order), notice: 'La solicitud se ha enviado correctamente.' }
      rescue ArgumentError => e
        flash[:alert] = e.message
        @external_order_product = @external_order.order_products.build
        @error = e.message
        format.html { render :edit_products }
      end
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
    super
  end

  private

  def new_from_template(template_id, order_type)
    # Buscamos el template
    @external_order_template = ExternalOrderTemplate.find_by(id: template_id, order_type: order_type)
    # Seteamos los productos a la orden
    @external_order_template.external_order_product_templates.joins(:product).order('name').each do |iots|
      @external_order.order_products.build(id: DateTime.now.to_s(:number), product_id: iots.product_id)
    end
  end

  def set_last_requests
    @last_requests = current_user.sector_applicant_external_orders.order(created_at: :asc).last(10)
  end
end
