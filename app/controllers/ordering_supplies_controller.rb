class OrderingSuppliesController < ApplicationController
  before_action :set_ordering_supply, only: [:show, :edit, :update, :send_provider,
    :send_applicant, :destroy, :delete, :return_status, :edit_receipt,
    :receive_applicant_confirm, :receive_applicant, :receive_order, :receive_order_confirm ]

  # GET /ordering_supplies
  # GET /ordering_supplies.json
  def index
    authorize OrderingSupply
    @filterrific = initialize_filterrific(
      OrderingSupply.provider(current_user.sector),
      params[:filterrific],
      select_options: {
        sorted_by: OrderingSupply.options_for_sorted_by
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'created_at_desc'},
      available_filters: [
        :search_applicant,
        :search_provider,
        :search_supply_code,
        :search_supply_name,
        :sorted_by,
      ],
    ) or return
    @ordering_supplies = @filterrific.find.page(params[:page]).per_page(10)
  end

  # GET /ordering_supplies
  # GET /ordering_supplies.json
  def applicant_index
    authorize OrderingSupply
    @filterrific = initialize_filterrific(
      OrderingSupply.applicant(current_user.sector),
      params[:filterrific],
      select_options: {
        sorted_by: OrderingSupply.options_for_sorted_by
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'created_at_desc'},
      available_filters: [
        :search_applicant,
        :search_provider,
        :search_supply_code,
        :search_supply_name,
        :sorted_by,
      ],
    ) or return
    @applicant_orders = @filterrific.find.page(params[:page]).per_page(10)
  end

  # GET /ordering_supplies/1
  # GET /ordering_supplies/1.json
  def show
    authorize @ordering_supply
  end

  # GET /ordering_supplies/new
  def new
    authorize OrderingSupply
    @ordering_supply = OrderingSupply.new
    4.times { @ordering_supply.quantity_ord_supply_lots.build }
  end

  # GET /ordering_supplies/new_receipt
  def new_receipt
    authorize OrderingSupply
    @ordering_supply = OrderingSupply.new
    4.times { @ordering_supply.quantity_ord_supply_lots.build }
  end

  # GET /ordering_supplies/new_applicant
  def new_applicant
    authorize OrderingSupply
    @ordering_supply = OrderingSupply.new
    4.times { @ordering_supply.quantity_ord_supply_lots.build }
  end

  # GET /ordering_supplies/1/edit_receipt
  def edit_receipt
    authorize @ordering_supply
    @ordering_supply.quantity_ord_supply_lots || @ordering_supply.quantity_ord_supply_lots.build
    @sectors = Sector.with_establishment_id(@ordering_supply.provider_sector.establishment_id)
  end

  # GET /ordering_supplies/1/edit
  def edit
    authorize @ordering_supply
    @ordering_supply.quantity_ord_supply_lots || @ordering_supply.quantity_ord_supply_lots.build
    @sectors = Sector.with_establishment_id(@ordering_supply.applicant_sector.establishment_id)
  end

  # Creación pedido despacho con estado proveedor_auditoria.
  # POST /ordering_supplies
  # POST /ordering_supplies.json
  def create
    @ordering_supply = OrderingSupply.new(ordering_supply_params)
    authorize @ordering_supply
    @ordering_supply.created_by = current_user
    @ordering_supply.audited_by = current_user
    respond_to do |format|
      if @ordering_supply.save
        @ordering_supply.proveedor_auditoria!
        # Si se acepta el pedido
        if accepting?
          begin
            @ordering_supply.accept_order(current_user)
            flash[:success] = 'El pedido se ha auditado y aceptado correctamente'
          rescue ArgumentError => e
            flash[:alert] = 'No se ha podido aceptar: '+e.message
          end
        else
          flash[:notice] = 'El pedido se ha creado y se encuentra en auditoría.'
        end
        format.html { redirect_to @ordering_supply }
      else
        4.times { @ordering_supply.quantity_ord_supply_lots.build }
        @sectors = Sector.with_establishment_id(@ordering_supply.applicant_sector.establishment_id)
        flash[:error] = "El pedido no se ha podido crear."
        format.html { render :new }
      end
    end
  end

  # POST /ordering_supplies/create_receipt
  def create_receipt
    @ordering_supply = OrderingSupply.new(ordering_supply_params)
    authorize @ordering_supply
    @ordering_supply.created_by = current_user
    @ordering_supply.audited_by = current_user
    respond_to do |format|
      if @ordering_supply.save
        @ordering_supply.recibo! # Se asigna el tipo recibo
        @ordering_supply.recibo_auditoria! # Se asigna el estado recibo auditoria
        # Si se recibe el recibo
        if receiving?
          begin
            @ordering_supply.receive_remit(current_user)
            flash[:success] = 'El recibo se ha auditado y recibido correctamente'
          rescue ArgumentError => e
            flash[:alert] = 'No se ha podido recibir: '+e.message
          end
        else
          flash[:notice] = 'El recibo se ha cargado y se encuentra en auditoría.'
        end
        format.html { redirect_to @ordering_supply }
      else
        4.times { @ordering_supply.quantity_ord_supply_lots.build }
        @sectors = Sector.with_establishment_id(@ordering_supply.provider_sector.establishment_id)
        flash[:error] = "El recibo no se ha podido cargar."
        format.html { render :new_receipt }
      end
    end
  end

  # POST /ordering_supplies/create_applicant
  def create_applicant
    @ordering_supply = OrderingSupply.new(ordering_supply_params)
    authorize @ordering_supply
    @ordering_supply.audited_by = current_user
    respond_to do |format|
      if @ordering_supply.save
        # Si se acepta el pedido
        if accepting?
          begin
            @ordering_supply.accepted_by = current_user
            @ordering_supply.accept_order
            flash[:success] = 'El pedido se ha auditado y aceptado correctamente'
          rescue ArgumentError => e
            flash[:alert] = 'No se ha podido aceptar: '+e.message
          end
        else
          flash[:notice] = 'El pedido se ha creado y se encuentra en auditoría.'
        end
        format.html { redirect_to @ordering_supply }
      else
        4.times { @ordering_supply.quantity_ord_supply_lots.build }
        @sectors = Sector.with_establishment_id(@ordering_supply.applicant_sector.establishment_id)
        flash[:error] = "El pedido no se ha podido crear."
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /ordering_supplies/1
  # PATCH/PUT /ordering_supplies/1.json
  def update
    authorize @ordering_supply
    respond_to do |format|
      if @ordering_supply.update(ordering_supply_params)
        # Si se acepta el pedido
        if accepting?
          begin
            @ordering_supply.accept_order(current_user)
            flash[:success] = 'El pedido se ha auditado y aceptado correctamente'
          rescue ArgumentError => e
            flash[:alert] = 'No se ha podido aceptar: '+e.message
          end
        elsif sending?
          begin
            @ordering_supply.send_order(current_user)
            flash[:success] = 'El pedido se ha enviado correctamente'
          rescue ArgumentError => e
            flash[:alert] = 'No se ha podido enviar: '+e.message
          end
        elsif receiving?
          begin
            @ordering_supply.receive_remit(current_user)
            flash[:success] = 'El recibo se ha realizado correctamente'
          rescue ArgumentError => e
            flash[:alert] = 'No se ha podido realizar: '+e.message
          end
        else
          flash[:notice] = 'El '+@ordering_supply.order_type+' se ha auditado correctamente.'
        end
        format.html { redirect_to @ordering_supply }
      else
        @sectors = Sector.with_establishment_id(@ordering_supply.applicant_sector.establishment_id)
        format.html { render :edit }
        format.json { render json: @ordering_supply.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /ordering_supplies/1/send_provider
  def send_provider
    authorize @ordering_supply
    @users = User.with_sector_id(current_user.sector_id)
    respond_to do |format|
      format.js
    end
  end

  # GET /ordering_supplies/1/accept_provider
  def accept_provider
    authorize @ordering_supply
    respond_to do |format|
      format.js
    end
  end

  # GET /ordering_supplies/1/accept_provider_confirm
  def accept_provider_confirm
    respond_to do |format|
      format.js
    end
  end

  # GET /ordering_supplies/1/receive_order
  def receive_order
    authorize @ordering_supply
    respond_to do |format|
      begin
        if @ordering_supply.recibo?
          @ordering_supply.receive_remit(current_user)
          flash[:success] = 'El recibo se ha realizado correctamente'
        elsif
          @ordering_supply.despacho?
          @ordering_supply.receive_order(current_user)
          flash[:success] = 'El despacho se ha recibido correctamente'
        end
      rescue ArgumentError => e
        flash[:error] = 'No se ha podido realizar: '+e.message
      else
      format.html { redirect_to @ordering_supply }
      end
    end
  end

  # GET /ordering_supplies/1/receive_order_confirm
  def receive_order_confirm
    respond_to do |format|
      format.js
    end
  end

  def return_status
    authorize @ordering_supply
    respond_to do |format|
      begin
        @ordering_supply.return_status
      rescue ArgumentError => e
        flash[:alert] = e.message
      else
        flash[:notice] = 'El pedido se ha retornado a un estado anterior.'
      end
      format.html { redirect_to @ordering_supply }
    end
  end

  # DELETE /ordering_supplies/1
  # DELETE /ordering_supplies/1.json
  def destroy
    authorize @ordering_supply
    @sector_name = @ordering_supply.applicant_sector.name
    @ordering_supply.destroy
    respond_to do |format|
      flash.now[:success] = "El pedido de "+@sector_name+" se ha enviado a la papelera."
      format.js
    end
  end

  # GET /ordering_supply/1/delete
  def delete
    authorize @ordering_supply
    respond_to do |format|
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ordering_supply
      @ordering_supply = OrderingSupply.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ordering_supply_params
      params.require(:ordering_supply).permit(:applicant_sector_id, :provider_sector_id,
      :requested_date, :sector_id, :observation, :sent_by_id, :remit_code,
        quantity_ord_supply_lots_attributes: [:id, :supply_lot_id, :supply_id, :sector_supply_lot_id,
          :requested_quantity, :delivered_quantity, :lot_code, :laboratory_id, :expiry_date,
          :_destroy
        ]
      )
    end

    def accepting?
      submit = params[:commit]
      return submit == "Auditar y aceptar" || submit == "Aceptar"
    end

    def receiving?
      submit = params[:commit]
      return submit == "Recibir" || submit == "Auditar y recibir"
    end

    def sending?
      submit = params[:commit]
      return submit == "Enviar" || submit == "Auditar y enviar"
    end

    def save_my_previous_url
      # session[:previous_url] is a Rails built-in variable to save last url.
      session[:my_previous_url] = URI(request.referer || '').path
    end
end
