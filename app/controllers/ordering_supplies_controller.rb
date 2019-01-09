class OrderingSuppliesController < ApplicationController
  before_action :set_ordering_supply, only: [:show, :edit, :update, :send_provider,
    :send_applicant, :destroy, :delete, :return_status, :edit_receipt, :edit_applicant,
    :receive_applicant_confirm, :receive_applicant, :receive_order, :receive_order_confirm ]

  def statistics
    
  end

  # GET /ordering_supplies
  # GET /ordering_supplies.json
  def index
    authorize OrderingSupply
    @filterrific = initialize_filterrific(
      OrderingSupply.provider(current_user.sector),
      params[:filterrific],
      select_options: {
        sorted_by: OrderingSupply.options_for_sorted_by,
        with_status: OrderingSupply.options_for_status
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'created_at_desc'},
      available_filters: [
        :search_code,
        :search_applicant,
        :search_provider,
        :with_order_type,
        :with_status,
        :requested_date_since,
        :requested_date_to,
        :date_received_since,
        :date_received_to,
        :sorted_by
      ],
    ) or return
    @ordering_supplies = @filterrific.find.page(params[:page]).per_page(15)
  end

  # GET /ordering_supplies
  # GET /ordering_supplies.json
  def applicant_index
    authorize OrderingSupply
    @filterrific = initialize_filterrific(
      OrderingSupply.applicant(current_user.sector),
      params[:filterrific],
      select_options: {
        sorted_by: OrderingSupply.options_for_sorted_by,
        with_status: OrderingSupply.options_for_status
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'created_at_desc'},
      available_filters: [
        :search_code,
        :search_provider,
        :with_order_type,
        :with_status,
        :requested_date_since,
        :requested_date_to,
        :date_received_since,
        :date_received_to,
        :sorted_by
      ],
    ) or return
    @applicant_orders = @filterrific.find.page(params[:page]).per_page(15)
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
    @order_type = 'despacho'
  end

  # GET /ordering_supplies/new_receipt
  def new_receipt
    authorize OrderingSupply
    @ordering_supply = OrderingSupply.new
    4.times { @ordering_supply.quantity_ord_supply_lots.build }
    @order_type = 'recibo'
  end

  # GET /ordering_supplies/new_applicant
  def new_applicant
    authorize OrderingSupply
    @ordering_supply = OrderingSupply.new
    4.times { @ordering_supply.quantity_ord_supply_lots.build }
    @order_type = 'solicitud_abastecimiento'
  end

  # GET /ordering_supplies/1/edit
  def edit
    authorize @ordering_supply
    @order_type = 'despacho'
    @ordering_supply.quantity_ord_supply_lots || @ordering_supply.quantity_ord_supply_lots.build
    @sectors = Sector.with_establishment_id(@ordering_supply.applicant_sector.establishment_id)
  end

  # GET /ordering_supplies/1/edit_receipt
  def edit_receipt
    authorize @ordering_supply
    @order_type = 'recibo'
    @ordering_supply.quantity_ord_supply_lots || @ordering_supply.quantity_ord_supply_lots.build
    @sectors = Sector.with_establishment_id(@ordering_supply.provider_sector.establishment_id)
  end

  # GET /ordering_supplies/1/edit_applicant
  def edit_applicant
    authorize @ordering_supply
    @order_type = 'solicitud_abastecimiento'
    @ordering_supply.quantity_ord_supply_lots || @ordering_supply.quantity_ord_supply_lots.build
    @sectors = Sector.with_establishment_id(@ordering_supply.provider_sector.establishment_id)
  end

  # Creación despacho o recibo
  # POST /ordering_supplies
  # POST /ordering_supplies.json
  def create
    @ordering_supply = OrderingSupply.new(ordering_supply_params)
    authorize @ordering_supply
    @ordering_supply.created_by = current_user
    @ordering_supply.audited_by = current_user
    respond_to do |format|
      if @ordering_supply.save
        begin
          if @ordering_supply.despacho?
            @ordering_supply.proveedor_auditoria!
            # Si se acepta el despacho
            if accepting?
              @ordering_supply.accept_order(current_user)
              @ordering_supply.create_notification(current_user, "creó y aceptó")
              flash[:success] = 'El despacho se ha creado y aceptado correctamente'
            else
              @ordering_supply.create_notification(current_user, "creó")
              flash[:notice] = 'El despacho se ha creado y se encuentra en auditoría.'
            end
          elsif @ordering_supply.recibo?
            @ordering_supply.recibo! # Se asigna el tipo recibo
            @ordering_supply.recibo_auditoria! # Se asigna el estado recibo auditoria
            if receiving?
              @ordering_supply.receive_remit(current_user)
              @ordering_supply.create_notification(current_user, "creó y realizó")
              flash[:success] = 'El recibo se ha creado y realizado correctamente'
            else
              @ordering_supply.create_notification(current_user, "creó")
              flash[:notice] = 'El recibo se ha creado y se encuentra en auditoría.'
            end
          elsif @ordering_supply.solicitud_abastecimiento?
            @ordering_supply.solicitud_abastecimiento! # Se asigna el tipo solicitud abastecimiento.
            @ordering_supply.solicitud_auditoria!
            if sending?
              @ordering_supply.send_request_of(current_user)
              @ordering_supply.create_notification(current_user, "creó y envió")
              flash[:success] = 'La solicitud de abastecimiento se ha creado y enviado correctamente'
            else
              @ordering_supply.create_notification(current_user, "creó")
              flash[:notice] = 'La solicitud de abastecimiento se ha creado y se encuentra en auditoría.'
            end
          end
        rescue ArgumentError => e
          flash[:alert] = e.message
        end
        format.html { redirect_to @ordering_supply }
      else
        if ordering_supply_params[:order_type] == 'despacho'
          @order_type = 'despacho'
          @sectors = Sector.with_establishment_id(@ordering_supply.applicant_sector.establishment_id)
          flash[:error] = "El despacho no se ha podido crear."
          format.html { render :new }
        elsif ordering_supply_params[:order_type] == 'recibo'
          @order_type = 'recibo'
          @sectors = Sector.with_establishment_id(@ordering_supply.provider_sector.establishment_id)
          flash[:error] = "El recibo no se ha podido crear."
          format.html { render :new_receipt }
        elsif ordering_supply_params[:order_type] == 'solicitud_abastecimiento'
          @order_type = 'solicitud_abastecimiento'
          @sectors = Sector.with_establishment_id(@ordering_supply.provider_sector.establishment_id)
          flash[:error] = "La solicitud de abastecimiento no se ha podido crear."
          format.html { render :new_applicant }
        end
      end
    end
  end

  # PATCH/PUT /ordering_supplies/1
  # PATCH/PUT /ordering_supplies/1.json
  def update
    authorize @ordering_supply
    respond_to do |format|
      if @ordering_supply.update(ordering_supply_params)
        begin
          if @ordering_supply.despacho?  
            if accepting? # Si se acepta el despacho
              @ordering_supply.accept_order(current_user)
              @ordering_supply.create_notification(current_user, "auditó y aceptó")
              flash[:success] = 'El despacho se ha auditado y aceptado correctamente'
            elsif sending? # Si se envía el despacho
              @ordering_supply.send_order(current_user)
              @ordering_supply.create_notification(current_user, "auditó y envió")
              flash[:success] = 'El despacho se ha auditado y enviado correctamente'
            else
              @ordering_supply.create_notification(current_user, "auditó")
              flash[:success] = 'El despacho se ha auditado correctamente'
            end
          elsif @ordering_supply.recibo?
            if receiving?
              @ordering_supply.receive_remit(current_user)
              @ordering_supply.create_notification(current_user, "auditó y realizó")
              flash[:success] = 'El recibo se ha auditado y realizado correctamente'
            else
              @ordering_supply.create_notification(current_user, "auditó")
              flash[:success] = 'El recibo se ha auditado correctamente'
            end
          elsif @ordering_supply.solicitud_abastecimiento?
            if sending?
              if @ordering_supply.provider_sector == current_user.sector
                @ordering_supply.send_order(current_user)
                @ordering_supply.create_notification(current_user, "auditó y envió")
                flash[:success] = 'La solicitud de abastecimiento se ha auditado y aprovisionado correctamente'
              else
                @ordering_supply.send_request_of(current_user)
                @ordering_supply.create_notification(current_user, "auditó y envió")
                flash[:success] = 'La solicitud de abastecimiento se ha auditado y enviado correctamente'
              end
            else
              if @ordering_supply.solicitud_enviada?
                @ordering_supply.proveedor_auditoria!
                @ordering_supply.create_notification(current_user, "auditó")
                flash[:success] = 'La solicitud de abastecimiento se ha auditado correctamente'
              elsif @ordering_supply.proveedor_auditoria?
                @ordering_supply.accept_order(current_user)
                @ordering_supply.create_notification(current_user, "auditó y aceptó")
                flash[:success] = 'La solicitud de abastecimiento se ha auditado y aceptado correctamente'
              else
                @ordering_supply.create_notification(current_user, "auditó")
                flash[:success] = 'La solicitud de abastecimiento se ha auditado correctamente'
              end
            end
          end   
        rescue ArgumentError => e
          flash[:alert] = e.message
        end
        format.html { redirect_to @ordering_supply }
      else
        if @ordering_supply.despacho?
          @order_type = 'despacho'
          @sectors = Sector.with_establishment_id(@ordering_supply.applicant_sector.establishment_id)
          flash[:error] = "El despacho no se ha podido auditar."
          format.html { render :edit }
        elsif @ordering_supply.recibo?
          @order_type = 'recibo'
          @sectors = Sector.with_establishment_id(@ordering_supply.provider_sector.establishment_id)
          flash[:error] = "El recibo no se ha podido auditar."
          format.html { render :edit_receipt }
        elsif @ordering_supply.solicitud_abastecimiento?
          @sectors = Sector.with_establishment_id(@ordering_supply.provider_sector.establishment_id)
          @order_type = 'solicitud_abastecimiento'
          flash[:error] = "La solicitud de abastecimiento no se ha podido auditar."
          format.html { render :edit_applicant }
        end
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
          @ordering_supply.create_notification(current_user, "realizó")
          flash[:success] = 'El recibo se ha realizado correctamente'
        elsif @ordering_supply.despacho?
          @ordering_supply.receive_order(current_user)
          @ordering_supply.create_notification(current_user, "recibió")
          flash[:success] = 'El despacho se ha recibido correctamente'
        elsif @ordering_supply.solicitud_abastecimiento?
          @ordering_supply.receive_order(current_user)
          @ordering_supply.create_notification(current_user, "recibió")
          flash[:success] = 'El pedido soliciado se ha recibido correctamente'
        end
      rescue ArgumentError => e
        flash[:error] = e.message
      end 
      format.html { redirect_to @ordering_supply }
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
        @ordering_supply.create_notification(current_user, "retornó a un estado anterior")
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
    @order_type = @ordering_supply.order_type
    Notification.destroy_with_target_id(@ordering_supply.id)
    @ordering_supply.destroy
    @ordering_supply.create_notification(current_user, "envió a la papelera")
    respond_to do |format|
      flash.now[:success] = @order_type.humanize+" de "+@sector_name+" se ha enviado a la papelera."
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
      :requested_date, :sector_id, :observation, :sent_by_id, :remit_code, :order_type,
        quantity_ord_supply_lots_attributes: [:id, :supply_lot_id, :supply_id, :sector_supply_lot_id,
          :requested_quantity, :delivered_quantity, :lot_code, :laboratory_id, :expiry_date, 
          :applicant_observation, :provider_observation, :_destroy
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
