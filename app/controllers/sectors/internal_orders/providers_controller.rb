class Sectors::InternalOrders::ProvidersController < Sectors::InternalOrders::InternalOrderController
  include FindLots

  before_action :set_internal_order, only: %i[show destroy edit update rollback_order dispatch_order nullify_order]
  before_action :set_sectors, only: %i[new edit create update]

  # GET /internal_orders/provider
  # GET /internal_orders/provider.json
  def index
    policy(:internal_order_provider).index?
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

  # GET /internal_orders/provider/new
  def new
    policy(:internal_order_provider).new?
    @last_delivers = current_user.sector_provider_internal_orders.order(created_at: :asc).last(10)
    begin
      new_from_template(params[:template], 'provision')
    rescue
      flash[:error] = 'No se ha encontrado la plantilla' if params[:template].present?
      @internal_order = InternalOrder.new
      @internal_order.order_type = 'provision'
      @internal_order.order_products.build
    end
  end

  # GET /internal_orders/provider/1/edit
  def edit
    policy(:internal_order_provider).edit?(@internal_order)
    @last_delivers = current_user.sector_provider_internal_orders.order(created_at: :asc).last(10)
  end

  # GET /sectors/internal_orders/applicants/:id/edit_products(.:format)
  def edit_products
    policy(:internal_order_provider).edit_products?(@internal_order)
    @internal_order_product = @internal_order.order_products.build
    @form_id = DateTime.now.to_s(:number)
  end

  def create
    policy(:internal_order_provider).create?
    @internal_order = InternalOrder.new(internal_order_params)
    @internal_order.created_by = current_user
    @internal_order.audited_by = current_user
    @internal_order.requested_date = DateTime.now
    @internal_order.provider_sector = current_user.sector
    @internal_order.order_type = 'provision'
    @internal_order.status = sending? ? 'provision_en_camino' : 'proveedor_auditoria'

    respond_to do |format|
      begin
        @internal_order.save!

        @internal_order.send_order_by(current_user) if sending?

        message = sending? ? "La provisión interna de "+@internal_order.applicant_sector.name+" se ha auditado y enviado correctamente." :message = "La provisión interna de "+@internal_order.applicant_sector.name+" se ha auditado correctamente."
        format.html { redirect_to internal_orders_provider_url(@internal_order), notice: message }
      rescue ArgumentError => e
        # si fallo la validacion de stock debemos modificar el estado a proveedor_auditoria
        @internal_order.proveedor_auditoria!
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure  
        @sectors = Sector
          .select(:id, :name)
          .with_establishment_id(current_user.sector.establishment_id)
          .where.not(id: current_user.sector_id).as_json
        @order_products = @internal_order.order_products.present? ? @internal_order.order_products : @internal_order.order_products.build
        format.html { render :new }
      end
    end
  end

  # PATCH /internal_orders/provider
  # PATCH /internal_orders/provider.json
  def update
    policy(:internal_order_provider).update?(@internal_order)
    previous_status = @internal_order.status
    @internal_order.audited_by = current_user
    @internal_order.status = sending? ? "provision_en_camino" : 'proveedor_auditoria'

    respond_to do |format|
      begin
        @internal_order.update!(internal_order_params)

        @internal_order.send_order_by(current_user) if sending?

        message = sending? ? 'La provision se ha enviado correctamente.' : 'La solicitud se ha editado y se encuentra en auditoria.'

        format.html { redirect_to internal_orders_provider_url(@internal_order), notice: message }
      rescue ArgumentError => e
        # si fallo la validación de stock, debemos volver atras el estado de la orden
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @internal_order.status = previous_status
        @sectors = Sector
          .select(:id, :name)
          .with_establishment_id(current_user.sector.establishment_id)
          .where.not(id: current_user.sector_id).as_json
          @order_products = @internal_order.order_products.present? ? @internal_order.order_products : @internal_order.order_products.build
        format.html { render :edit }
      end
    end
  end

  # # GET /internal_order/provider/1/dispatch_order
  def dispatch_order
    policy(:internal_order_provider).dispatch_order?(@internal_order)
    previous_status = @internal_order.status
    respond_to do |format|
      begin
        @internal_order.status = 'provision_en_camino'
        @internal_order.save!

        @internal_order.send_order_by(current_user)
        message = 'La provision se ha enviado correctamente.'

        format.html { redirect_to internal_orders_provider_url(@internal_order), notice: message }
      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @internal_order.status = previous_status
        @sectors = Sector.select(:id, :name)
                          .with_establishment_id(current_user.sector.establishment_id)
                          .where.not(id: current_user.sector_id).as_json
        @order_products = @internal_order.order_products.present? ? @internal_order.order_products : @internal_order.order_products.build
        format.html { render :edit }
      end
    end
  end

  def rollback_order
    policy(:internal_order_provider).rollback_order?(@internal_order)
    respond_to do |format|
      begin
        @internal_order.return_provider_status_by(current_user)
        flash[:notice] = 'La '+@internal_order.order_type+' se ha retornado a un estado anterior.'
      rescue ArgumentError => e
        flash[:alert] = e.message
      end
      format.html { redirect_to internal_orders_provider_url(@internal_order) }
    end
  end

  # get /internal_orders/provider/1/nullify_order
  def nullify_order
    policy(:internal_order_provider).nullify_order?(@internal_order)
    @internal_order.nullify_by(current_user)
    respond_to do |format|
      flash[:success] = "#{@internal_order.order_type.humanize} se ha anulado correctamente."
      format.html { redirect_to internal_orders_provider_url(@internal_order) }
    end
  end

  # DELETE /internal_orders/providers/1
  def destroy
    policy(:internal_order_provider).destroy?(@internal_order)
    super
  end

  private

  def set_sectors
    @sectors = Sector.select(:id, :name)
                     .with_establishment_id(current_user.sector.establishment_id)
                     .where.not(id: current_user.sector_id).as_json
  end
end
