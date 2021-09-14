class Establishments::ExternalOrders::ProvidersController < Establishments::ExternalOrders::ExternalOrdersController
  include FindLots
  before_action :set_external_order, only: %i[show edit update dispatch_order rollback_order accept_order nullify_order
                                              edit_products destroy]
  before_action :set_last_delivers, only: %i[new edit create update]

  # GET /external_orders/providers
  # GET /external_orders/providers.json
  def index
    policy(:external_order_provider).index?
    @filterrific = initialize_filterrific(
      ExternalOrder.provider(current_user.sector).without_status(0),
      params[:filterrific],
      select_options: {
        with_status: ExternalOrder.options_for_status,
        sorted_by: ExternalOrder.options_for_sorted_by
      },
      persistence_id: false,
    ) or return
    @provider_orders = @filterrific.find.paginate(page: params[:page], per_page: 15)
  end

  # GET /external_orders/providers
  def new
    authorize :external_order_provider

    begin
      new_from_template(params[:template], 'provision')
    rescue
      flash[:error] = 'No se ha encontrado la plantilla' if params[:template].present?
      @external_order = ExternalOrder.new
      @external_order.order_type = 'provision'
      @sectors = []
      @external_order.order_products.build
    end
  end

  # GET /external_orders/providers/1/edit
  def edit
    policy(:external_order_provider).edit?(@external_order)
    @external_order.order_products || @external_order.order_products.build
    @sectors = @external_order.applicant_sector.present? ? @external_order.applicant_establishment.sectors : []
  end

  # PATCH /external_orders/providers
  # PATCH /external_orders/providers.json
  def create
    policy(:external_order_provider).create?
    @external_order = ExternalOrder.new(external_order_params)
    @external_order.requested_date = DateTime.now
    @external_order.provider_sector = current_user.sector
    @external_order.order_type = "provision"

    respond_to do |format|
      begin
        @external_order.proveedor_auditoria!
        @external_order.create_notification(current_user, "creó")
        message = 'La provisión se ha creado y se encuentra en auditoria.'

        format.html { redirect_to edit_products_external_orders_provider_url(@external_order), notice: message }
      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @external_order.order_products || @external_order.order_products.build
        @sectors = @external_order.applicant_sector.present? ? @external_order.applicant_establishment.sectors : []
        format.html { render :new }
      end
    end
  end

  # PATCH /external_orders/providers/1
  def update
    policy(:external_order_provider).update?(@external_order)
    respond_to do |format|
      begin
        @external_order.status = 'proveedor_auditoria'
        @external_order.update!(external_order_params)
        message = 'La provisión se ha auditado y se encuentra en auditoria.'
        @external_order.create_notification(current_user, 'auditó')

        format.html { redirect_to edit_products_external_orders_provider_url(@external_order), notice: message }
      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @external_order.order_products || @external_order.order_products.build
        @sectors = @external_order.applicant_sector.present? ? @external_order.applicant_establishment.sectors : []
        format.html { render :edit }
      end
    end
  end

  # GET /external_orders/providers/1/dispatch_order
  def dispatch_order
    policy(:external_order_provider).can_send?(@external_order)

    respond_to do |format|
      begin
        @external_order.send_order_by(current_user)

        format.html { redirect_to external_orders_provider_url(@external_order), notice: 'La provision se ha enviado correctamente.' }
      rescue ArgumentError => e
        # si fallo la validación de stock, debemos volver atras el estado de la orden
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @external_order.order_products || @external_order.order_products.build
        @sectors = @external_order.provider_sector.present? ? @external_order.provider_establishment.sectors : []
        format.html { render :edit }
      end
    end
  end

  # GET /external_orders/providers/1/accept_order
  def accept_order
    policy(:external_order_provider).accept_order?(@external_order)
    respond_to do |format|
      begin
        @external_order.accept_order_by(current_user)
        format.html { redirect_to external_orders_provider_url(@external_order), notice: 'La provision se ha aceptado correctamente.' }
      rescue ArgumentError => e
        # si fallo la validación de stock, debemos volver atras el estado de la orden
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @external_order.order_products || @external_order.order_products.build
        @sectors = @external_order.applicant_sector.present? ? @external_order.applicant_establishment.sectors : []
        format.html { render :edit }
      end
    end
  end

  # GET /external_orders/providers/1/rollback_order
  def rollback_order
    policy(:external_order_provider).rollback_order?(@external_order)
    respond_to do |format|
      begin
        @external_order.return_to_proveedor_auditoria_by(current_user)
      rescue ArgumentError => e
        flash[:alert] = e.message
      else
        flash[:notice] = 'El pedido se ha retornado a un estado anterior.'
      end
      format.html { redirect_to external_orders_provider_url(@external_order) }
    end
  end

  # GET /external_order/providers/1/nullify_order
  def nullify_order
    policy(:external_order_provider).nullify_order?(@external_order)
    @external_order.nullify_by(current_user)
    respond_to do |format|
      flash[:success] = "#{@external_order.order_type.humanize} se ha anulado correctamente."
      format.html { redirect_to external_orders_provider_url(@external_order) }
    end
  end

  def edit_products
    @external_order_product = @external_order.order_products.build
    @form_id = DateTime.now.to_s(:number)
  end

  # DELETE /external_orders/providers/1
  def destroy
    policy(:external_order_provider).destroy?(@external_order)
    super
  end

  def set_order_product
    @order_product = params[:order_product_id].present? ? ExternalOrderProduct.find(params[:order_product_id]) : ExternalOrderProduct.new
  end

  private

  def accepting?
    return params[:commit] == "accepting"
  end

  def set_last_delivers
    @last_delivers = current_user.sector_provider_external_orders.order(created_at: :asc).last(10)
  end
end
