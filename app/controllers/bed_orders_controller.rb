class BedOrdersController < ApplicationController
  before_action :set_bed_order, only: [:show, :edit, :update, :destroy]

  # GET /bed_orders
  # GET /bed_orders.json
  def index
    authorize BedOrder
    @filterrific = initialize_filterrific(
      BedOrder.establishment(current_user.sector.establishment),
      params[:filterrific],
      select_options: {
        with_status: BedOrder.options_for_status
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'created_at_desc'},
      available_filters: [
        :search_patient,
        :search_bed,
        :with_order_type,
        :with_status,
        :requested_date_since,
        :requested_date_to,
        :sorted_by
      ],
    ) or return
    @bed_orders = @filterrific.find.page(params[:page]).per_page(15)
  end

  # GET /bed_orders/bed_map
  def bed_map
    authorize BedOrder
    @beds = Bed.establishment(current_user.sector.establishment)
    @bedrooms = Bedroom.establishment(current_user.sector.establishment)
  end
    
  # GET /bed_orders/1
  # GET /bed_orders/1.json
  def show
    authorize @bed_order
  end

  # GET /bed_orders/new
  def new
    authorize BedOrder
    @bed_order = BedOrder.new
    @beds = Bed.joins(:bedroom).pluck(:id, :name, "bedrooms.name")
  end

  # GET /bed_orders/1/edit
  def edit
    authorize @bed_order
  end

  # POST /bed_orders
  # POST /bed_orders.json
  def create
    @bed_order = BedOrder.new(bed_order_params)
    authorize @bed_order

    respond_to do |format|
      if @bed_order.save
        @bed_order.create_notification(current_user, "creó")
        format.html { redirect_to @bed_order, notice: 'El pedido de internación se ha creado correctamente.' }
        format.json { render :show, status: :created, location: @bed_order }
      else
        @beds = Bed.joins(:bedroom).pluck(:id, :name, "bedrooms.name")
        format.html { render :new }
        format.json { render json: @bed_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bed_orders/1
  # PATCH/PUT /bed_orders/1.json
  def update
    authorize @bed_order
    respond_to do |format|
      if @bed_order.update(bed_order_params)
        format.html { redirect_to @bed_order, notice: 'El pedido de internación se ha modificado correctamente.' }
        format.json { render :show, status: :ok, location: @bed_order }
      else
        format.html { render :edit }
        format.json { render json: @bed_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bed_orders/1
  # DELETE /bed_orders/1.json
  def destroy
    authorize @bed_order
    @bed_order.destroy
    respond_to do |format|
      format.html { redirect_to bed_orders_url, notice: 'El pedido de internación se ha enviado a la papelera correctamente.' }
      format.json { head :no_content }
    end
  end

  def new_bed
    authorize BedOrder
    @bed = Bed.new
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bed_order
      @bed_order = BedOrder.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bed_order_params
      params.require(:bed_order).permit(:status, :remit_code, :created_by_id, :audited_by_id, :sent_dy, :received_by_id, :sent_request_by_id_id, 
        :order_type, :bed_id, :requested_date, :observation, :sent_date, :deleted_at, :date_received, :patient_id, :establishment_id,
        quantity_ord_supply_lots_attributes: [:id, :supply_id, :sector_supply_lot_id,
        :requested_quantity, :delivered_quantity, :observation, :applicant_observation,
        :provider_observation, :_destroy]
      )
    end
end
