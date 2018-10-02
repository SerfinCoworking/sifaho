class InternalOrdersController < ApplicationController
  before_action :set_internal_order, only: [:show, :edit, :update, :destroy, :delete,
  :send_provider, :receive_applicant_confirm, :receive_applicant, :return_provider_status ]

  # GET /internal_orders
  # GET /internal_orders.json
  def index
    authorize InternalOrder
    @filterrific = initialize_filterrific(
      InternalOrder.provider(current_user.sector),
      params[:filterrific],
      select_options: {
        with_status: InternalOrder.options_for_status
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'created_at_desc'},
      available_filters: [
        :search_applicant,
        :search_provider,
        :search_supply_code,
        :search_supply_name,
        :with_status,
        :requested_date_at,
        :received_date_at
      ],
    ) or return
    @internal_orders = @filterrific.find.page(params[:page]).per_page(8)
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
        :search_provider,
        :search_supply_code,
        :search_supply_name,
        :with_status,
        :requested_date_at,
        :received_date_at
      ],
    ) or return
    @applicant_orders = @filterrific.find.page(params[:page]).per_page(8)
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

  # GET /internal_orders/new_applicant
  def new_applicant
    authorize InternalOrder
    @internal_order = InternalOrder.new
    @provider_sectors = Sector
      .select(:id, :name)
      .with_establishment_id(current_user.sector.establishment_id)
      .where.not(id: current_user.sector_id).as_json
    5.times { @internal_order.quantity_ord_supply_lots.build }
  end

  # GET /internal_orders/1/edit
  def edit
    authorize @internal_order
    @applicant_sectors = Sector
    .select(:id, :name)
    .with_establishment_id(current_user.sector.establishment_id)
    .where.not(id: current_user.sector_id).as_json
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
        5.times { @internal_order.quantity_ord_supply_lots.build }
        if @internal_order.despacho?
          @applicant_sectors = Sector
          .select(:id, :name)
          .with_establishment_id(current_user.sector.establishment_id)
          .where.not(id: current_user.sector_id).as_json
          
          flash[:error] = "El despacho no se ha podido crear."
          format.html { render :new_provider }
        elsif @internal_order.recibo?
          @provider_sectors = Sector
          .select(:id, :name)
          .with_establishment_id(current_user.sector.establishment_id)
          .where.not(id: current_user.sector_id).as_json
          
          flash[:error] = "El recibo no se ha podido crear."
          format.html { render :new_receipt }
        end
      end
    end
  end

  # POST /ordering_supplies/create_receipt
  def create_applicant
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
        @provider_sectors = Sector
        .select(:id, :name)
        .with_establishment_id(current_user.sector.establishment_id)
        .where.not(id: current_user.sector_id).as_json
        5.times { @internal_order.quantity_ord_supply_lots.build }
        flash[:error] = "El pedido interno no se ha podido crear."
        format.html { render :new_applicant }
      end
    end
  end

  # PATCH/PUT /internal_orders/1
  # PATCH/PUT /internal_orders/1.json
  def update
    authorize @internal_order
    respond_to do |format|
      if @internal_order.update(internal_order_params)
        # Si se acepta el pedido
        if sending?
          begin
            @internal_order.send_order
            flash[:success] = 'El pedido se ha enviado correctamente'
          rescue ArgumentError => e
            @internal_order.sent_by = nil; @internal_order.save
            flash[:alert] = 'No se ha podido enviar: '+e.message
          end
        else
          flash[:notice] = 'El pedido se ha auditado correctamente.'
        end
        format.html { redirect_to @internal_order }
      else
        @sectors = Sector.with_establishment_id(@internal_order.applicant_sector.establishment_id)
        format.html { render :edit }
        format.json { render json: @internal_order.errors, status: :unprocessable_entity }
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

  # GET /internal_order/1/send_provider
  def send_provider
    authorize @internal_order
    @users = User.with_sector_id(current_user.sector_id)
    respond_to do |format|
      format.js
    end
  end

  # GET /internal_orders/1/receive_applicant
  def receive_applicant
    authorize @internal_order
    respond_to do |format|
      begin
        @internal_order.received_by = current_user
        @internal_order.receive_order(current_user.sector)
        flash[:success] = 'El pedido se ha recibido correctamente'
      rescue ArgumentError => e
        flash[:error] = 'No se ha podido recibir: '+e.message
      else
      format.html { redirect_to @internal_order }
      end
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
      rescue ArgumentError => e
        flash[:alert] = 'No se ha podido retornar: '+e.message
      else
        flash[:notice] = 'El pedido se ha retornado a un estado anterior.'
      end
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
      params.require(:internal_order).permit(:applicant_sector_id, :sent_by_id,
        :provider_sector_id, :requested_date, :date_received, :observation, :remit_code,
        quantity_ord_supply_lots_attributes: [:id, :supply_id, :sector_supply_lot_id,
          :requested_quantity, :delivered_quantity, :observation,
          :_destroy]
        )
    end

    # Se verifica si el value del submit del form es para enviar
    def sending?
      submit = params[:commit]
      return submit == "Auditar y enviar" || submit == "Enviar"
    end

    # Se verifica si el value del submit del form es para enviar
    def auditing?
      submit = params[:commit]
      return submit == "Auditar" || submit == "Auditar y enviar"
    end
end
