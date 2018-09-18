class InternalOrdersController < ApplicationController
  before_action :set_internal_order, only: [:show, :edit, :update, :destroy, :delete]

  # GET /internal_orders
  # GET /internal_orders.json
  def index
    authorize InternalOrder
    @filterrific = initialize_filterrific(
      InternalOrder,
      params[:filterrific],
      select_options: {
        sorted_by: InternalOrder.options_for_sorted_by
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'created_at_desc'},
      available_filters: [
        :search_responsable,
        :search_supply_code,
        :search_supply_name,
        :sorted_by,
        :requested_date_at,
      ],
    ) or return
    @internal_orders = @filterrific.find.page(params[:page]).per_page(8)
  end
  
  # GET /internal_orders/1
  # GET /internal_orders/1.json
  def show
    authorize @internal_order
  end

  # GET /internal_orders/new
  def new
    authorize InternalOrder
    @internal_order = InternalOrder.new
    @providers = User.where.not(sector: current_user.sector_id )

    @internal_order.ord_quantity_supply_lots.build
  end

  # GET /internal_orders/new_deliver
  def new_provider
    authorize InternalOrder
    @internal_order = InternalOrder.new
    @applicant_sectors = Sector
      .select(:id, :name)
      .with_establishment_id(current_user.sector.establishment_id)
      .where.not(id: current_user.sector_id).as_json
    5.times { @internal_order.quantity_ord_supply_lots.build }
  end

  # GET /internal_orders/1/edit
  def edit
    authorize @internal_order
    @responsables = User.all
    @supplies = SupplyLot.all
  end

  # POST /internal_orders
  # POST /internal_orders.json
  def create
    @internal_order = InternalOrder.new(internal_order_params)
    authorize @internal_order

    respond_to do |format|
      if @internal_order.save
        # Si se carga y entrega el pedido
        if sending?
          begin
            @internal_order.send
            flash[:success] = "El pedido interno de "+@internal_order.applicant_sector.name+" se ha auditado y enviado correctamente."
          rescue ArgumentError => e
            flash[:notice] = "Se ha auditado pero no se ha podido enviar: "+e.message
          end
        elsif auditing?
          @internal_order.audited_by = current_user
          @internal_order.provider_auditoria!
          flash[:success] = "El pedido interno de "+@internal_order.applicant_sector.name+" se ha auditado correctamente."
        end
        @internal_order.created_by = current_user
        @internal_order.save
        format.html { redirect_to @internal_order }
      else
        @applicant_sectors = Sector
        .select(:id, :name)
        .with_establishment_id(current_user.sector.establishment_id)
        .where.not(id: current_user.sector_id).as_json
        5.times { @internal_order.quantity_ord_supply_lots.build }
        flash[:error] = "El pedido interno no se ha podido crear."
        format.html { render :new_provider }
      end
    end
  end

  # PATCH/PUT /internal_orders/1
  # PATCH/PUT /internal_orders/1.json
  def update
    authorize @internal_order

    respond_to do |format|
      if @internal_order.update_attributes(internal_order_params)
        # Si se carga y entrega el pedido
        if delivering?
          begin
            @internal_order.deliver
            flash.now[:success] = "El pedido interno de "+@internal_order.responsable.sector.name+" se ha modificado y entregado correctamente."
          rescue ArgumentError => e
            flash.now[:notice] = "Se ha modificado pero no se ha podido entregar: "+e.message
          end
        else
          flash.now[:success] = "El pedido interno de "+@internal_order.responsable.sector.name+" se ha modificado correctamente."
        end
        format.js
      else
        flash.now[:error] = "El pedido interno de "+@internal_order.responsable.sector.name+" no se ha podido modificar."
        format.js
      end
    end
  end

  # DELETE /internal_orders/1
  # DELETE /internal_orders/1.json
  def destroy
    authorize @internal_order
    # @name = @internal_order.responsable.sector.name
    @internal_order.destroy
    respond_to do |format|
      flash.now[:success] = "El pedido interno de se ha eliminado correctamente."
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

  # GET /internal_orders/1/dispense
  def deliver
    authorize @internal_order
    respond_to do |format|
      begin
        @internal_order.deliver

      rescue ArgumentError => e
        flash.now[:error] = e.message
        format.js
      else
        if @internal_order.save!
          flash.now[:success] = "El pedido interno de "+@internal_order.applicant.full_name+" se ha entregado correctamente."
          format.js
        else
          flash.now[:error] = "El pedido interno no se ha podido entregar."
          format.js
        end
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_internal_order
      @internal_order = InternalOrder.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def internal_order_params
      params.require(:internal_order).permit(:applicant_sector_id, :sent_by_id,
        :provider_sector_id, :requested_date, :date_received, :observation,
        quantity_ord_supply_lots_attributes: [:id, :supply_id, :sector_supply_lot_id,
          :requested_quantity, :delivered_quantity,
          :_destroy]
        )
    end

    # Se verifica si el value del submit del form es para enviar
    def sending?
      submit = params[:commit]
      return submit == "Auditar y enviar"
    end

    # Se verifica si el value del submit del form es para enviar
    def auditing?
      submit = params[:commit]
      return submit == "Auditar" || submit == "Auditar y enviar"
    end
end
