class Establishments::ExternalOrders::ProvidersController < Establishments::ExternalOrders::ExternalOrdersController
  include FindLots
  before_action :set_provider_order, only: [
    :edit,
    :update,
    :destroy,
    :delete,
    :dispatch_order,
    :rollback_order,
    :accept_order,
    :nullify_order
  ]

  # GET /external_orders
  # GET /external_orders.json
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

  # GET /external_orders/new_provider
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

  # GET /external_orders/1/edit
  def edit
    policy(:external_order_provider).edit?(@external_order)
    @external_order.order_products || @external_order.order_products.build
    @sectors = @external_order.applicant_sector.present? ? @external_order.applicant_establishment.sectors : []
  end

  # PATCH /external_orders
  # PATCH /external_orders.json
  def create
    policy(:external_order_provider).create?
    @external_order = ExternalOrder.new(external_order_params)
    @external_order.requested_date = DateTime.now
    @external_order.provider_sector = current_user.sector
    @external_order.order_type = "provision"

    respond_to do |format|
      begin
        if accepting?
          @external_order.accept_order_by(current_user)
        else
          @external_order.proveedor_auditoria!
          @external_order.create_notification(current_user, "creó")
        end
        message = accepting? ? 'La provisión se ha creado y aceptado correctamente.' : "La provisión se ha creado y se encuentra en auditoria."  

        format.html { redirect_to external_orders_provider_url(@external_order), notice: message }
      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @external_order.order_products || @external_order.order_products.build
        @sectors = @external_order.applicant_sector.present? ? @external_order.applicant_establishment.sectors : []
        format.html { render :new_provider }
      end
    end
  end

  # PATCH /external_orders
  # PATCH /external_orders.json
  def update
    policy(:external_order_provider).update?(@external_order)
    respond_to do |format|
      begin
        if accepting?
          @external_order.accept_order_by(current_user)
          message = 'La provisión se ha auditado y aceptado correctamente.'
        else
          @external_order.status = 'proveedor_auditoria'
          @external_order.update!(external_order_params)
          message = 'La provisión se ha auditado y se encuentra en auditoria.'
          @external_order.create_notification(current_user, "auditó")
        end

        format.html { redirect_to external_orders_provider_url(@external_order), notice: message }
      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @external_order.status = "proveedor_auditoria"
        @external_order.order_products || @external_order.order_products.build
        @sectors = @external_order.applicant_sector.present? ? @external_order.applicant_establishment.sectors : []
        format.html { render :edit_provider }
      end
    end
  end

  # GET /external_orders/1/send_provider
  def dispatch_order
    policy(:external_order_provider).can_send?(@external_order)

    respond_to do |format|
      begin
        @external_order.status = "provision_en_camino"
        @external_order.send_order_by(current_user)
        @external_order.save!

        format.html { redirect_to external_orders_provider_url(@external_order), notice: 'La provision se ha enviado correctamente.' }
      rescue ArgumentError => e
        # si fallo la validación de stock, debemos volver atras el estado de la orden
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @external_order.order_products || @external_order.order_products.build
        @sectors = @external_order.provider_sector.present? ? @external_order.provider_establishment.sectors : []
        format.html { render :edit_provider }
      end
    end
  end

  # GET /external_orders/1/accept_provider
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
        format.html { render :edit_provider }
      end
    end
  end

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

  # patch /external_order/1/nullify
  def nullify_order
    policy(:external_order_provider).nullify_order?(@external_order)
    @external_order.nullify_by(current_user)
    respond_to do |format|
      flash[:success] = "#{@external_order.order_type.humanize} se ha anulado correctamente."
      format.html { redirect_to external_orders_provider_url(@external_order) }
    end
  end

  def set_order_product
    @order_product = params[:order_product_id].present? ? ExternalOrderProduct.find(params[:order_product_id]) : ExternalOrderProduct.new
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_provider_order
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
