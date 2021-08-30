class Sectors::InternalOrders::ApplicantsController < Sectors::InternalOrders::InternalOrderController
  before_action :set_internal_order, only: %i[show destroy edit update receive_order rollback_order dispatch_order
                                              edit_products]
  before_action :set_sectors, only: %i[new edit create update]

  # GET /internal_orders/applicants
  # GET /internal_orders/applicants.json
  def index
    policy(:internal_order_applicant).index?
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

  # GET /internal_orders/applicants/new_applicant
  def new
    policy(:internal_order_applicant).new?
    @last_requests = current_user.sector_applicant_internal_orders.order(created_at: :asc).last(10)
    begin
      new_from_template(params[:template], 'solicitud')
    rescue
      flash[:error] = 'No se ha encontrado la plantilla' if params[:template].present?
      @internal_order = InternalOrder.new
      @internal_order.order_type = 'solicitud'
      @internal_order.order_products.build
    end
  end

  # GET /external_orders/1/edit_receipt
  def edit
    policy(:internal_order_applicant).edit?(@internal_order)
    @last_requests = current_user.sector_applicant_internal_orders.order(created_at: :asc).last(10)
  end

  # GET /sectors/internal_orders/applicants/:id/edit_products(.:format)
  def edit_products
    policy(:internal_order_applicant).edit_products?(@internal_order)
    @internal_order_product = @internal_order.order_products.build
    @form_id = DateTime.now.to_s(:number)
  end

  # POST /internal_orders/applicants
  # POST /internal_orders/applicants.json
  def create
    policy(:internal_order_applicant).create?
    @internal_order = InternalOrder.new(internal_order_params)
    @internal_order.created_by = current_user
    @internal_order.audited_by = current_user
    @internal_order.requested_date = DateTime.now
    @internal_order.applicant_sector = current_user.sector
    @internal_order.order_type = 'solicitud'

    respond_to do |format|
      if @internal_order.save
        flash[:info] = 'La solicitud se ha creado y se encuentra en auditoria.'
        format.html { redirect_to set_products_internal_orders_applicant_url(@internal_order) }
      else
        @last_requests = current_user.sector_applicant_internal_orders.order(created_at: :asc).last(10)
        format.html { render :new }
      end
    end
  end

  # PATCH /internal_orders/applicants
  # PATCH /internal_orders/applicants.json
  def update
    policy(:internal_order_applicant).update?(@internal_order)
    @internal_order.audited_by = current_user

    respond_to do |format|
      if @internal_order.update(internal_order_params)
        flash[:info] = 'La solicitud se ha modificado correctamente.'
        format.html { redirect_to internal_orders_applicant_url(@internal_order) }
      else
        flash[:alert] = 'No se ha podido modificar la solicitud.'
        format.html { render :edit }
      end
    end
  end

  # GET /external_orders/applicants/1/rollback_order
  def rollback_order
    policy(:internal_order_applicant).rollback_order?(@internal_order)
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
    policy(:internal_order_applicant).dispatch_order?(@internal_order)
    @internal_order.send_request_by(current_user)
    respond_to do |format|
      format.html { redirect_to internal_orders_applicant_url(@internal_order), notice: 'La solicitud se ha enviado correctamente.' }
    end
  end

  # GET /internal_orders/1/receive_applicant
  def receive_order
    policy(:internal_order_applicant).receive_order?(@internal_order)
    respond_to do |format|
      begin
        unless @internal_order.provision_en_camino?; raise ArgumentError, 'La provisión aún no está en camino.'; end
        @internal_order.receive_order_by(current_user)
        flash[:success] = 'La '+@internal_order.order_type+' se ha recibido correctamente'
      rescue ArgumentError => e
        flash[:error] = e.message
      end
      format.html { redirect_to internal_orders_applicant_url(@internal_order) }
    end
  end

  # DELETE /internal_orders/providers/1
  def destroy
    policy(:internal_order_provider).destroy?(@internal_order)
    super
  end

  private

  # Set sectors to select
  def set_sectors
    @sectors = Sector.select(:id, :name)
                     .with_establishment_id(current_user.sector.establishment_id)
                     .where.not(id: current_user.sector_id).as_json
  end
end
