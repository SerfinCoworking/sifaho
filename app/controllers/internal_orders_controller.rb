class InternalOrdersController < ApplicationController
  before_action :set_internal_order, only: [:show, :edit, :update, :destroy]

  # GET /internal_orders
  # GET /internal_orders.json
  def index
    @filterrific = initialize_filterrific(
      InternalOrder,
      params[:filterrific],
      select_options: {
        sorted_by: InternalOrder.options_for_sorted_by
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'created_at_desc'},
      available_filters: [
        :sorted_by,
        :search_query,
        :date_received_at,
      ],
    ) or return
    @internal_orders = @filterrific.find.page(params[:page]).per_page(8)


    respond_to do |format|
      format.html
      format.js
    end
    rescue ActiveRecord::RecordNotFound => e
      # There is an issue with the persisted param_set. Reset it.
      puts "Had to reset filterrific params: #{ e.message }"
      redirect_to(reset_filterrific_url(format: :html)) and return
  end

  # GET /internal_orders/1
  # GET /internal_orders/1.json
  def show
    respond_to do |format|
      format.js
    end
  end

  # GET /internal_orders/new
  def new
    @internal_orders = InternalOrder.new
    @responsables = User.all
    @medications = Medication.all
    @supplies = Supply.all
    @internal_orders.quantity_medications.build
    @internal_orders.quantity_supplies.build
  end

  # GET /internal_orders/1/edit
  def edit
    @professionals = User.all
    @medications = Medication.all
    @supplies = Supply.all
  end

  # POST /internal_orders
  # POST /internal_orders.json
  def create
    @internal_orders = Prescription.new(internal_orders_params)

    respond_to do |format|
      if @internal_orders.save!
        dispense if dispensing?
        flash.now[:success] = "El pedido interno de "+@internal_orders.responsable.sector.sector_name+" se ha creado correctamente."
        format.js
      else
        flash.now[:error] = "El pedido interno no se ha podido crear."
        format.js
      end
    end
  end

  # PATCH/PUT /internal_orders/1
  # PATCH/PUT /internal_orders/1.json
  def update
    @internal_order.dispensado! if dispensing?

    respond_to do |format|
      if @internal_order.update_attributes(internal_order_params)
        flash.now[:success] = "El pedido interno de "+@internal_order.responsable.sector.sector.sector_name+" se ha modificado correctamente."
        format.js
      else
        flash.now[:error] = "El pedido interno de "+@internal_order.responsable.sector.sector.sector_name+" no se ha podido modificar."
        format.js
      end
    end
  end

  # DELETE /internal_orders/1
  # DELETE /internal_orders/1.json
  def destroy
    @sector_name = @internal_order.sector.sector_name
    @internal_order.destroy
    respond_to do |format|
      flash.now[:success] = "El pedido interno de "+@sector_name+" se ha eliminado correctamente."
      format.js
    end
  end

  # GET /internal_orders/1/dispense
  def dispense
    respond_to do |format|
      if @internal_order.dispensado!
        flash.now[:success] = "El pedido interno de "+@internal_order.responsable.sector.sector_name+" se ha dispensado correctamente."
        format.js
      else
        flash.now[:error] = "El pedido interno no se ha podido dispensar."
        format.js
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
      params.require(:internal_order).permit(:responsable_id, :date_sent, :date_received, :observation)
    end

    # Se verifica si el value del submit del form es para dispensar
    def dispensing?
      submit = params[:commit]
      return submit == "Cargar y dispensar" || submit == "Guardar y dispensar"
    end
end
