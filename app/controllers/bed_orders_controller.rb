class BedOrdersController < ApplicationController
  before_action :set_bed_order, only: [:show, :edit, :update, :destroy]

  # GET /bed_orders
  # GET /bed_orders.json
  def index
    @bed_orders = BedOrder.all
  end

  # GET /bed_orders/1
  # GET /bed_orders/1.json
  def show
  end

  # GET /bed_orders/new
  def new
    @bed_order = BedOrder.new
  end

  # GET /bed_orders/1/edit
  def edit
  end

  # POST /bed_orders
  # POST /bed_orders.json
  def create
    @bed_order = BedOrder.new(bed_order_params)

    respond_to do |format|
      if @bed_order.save
        format.html { redirect_to @bed_order, notice: 'Bed order was successfully created.' }
        format.json { render :show, status: :created, location: @bed_order }
      else
        format.html { render :new }
        format.json { render json: @bed_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bed_orders/1
  # PATCH/PUT /bed_orders/1.json
  def update
    respond_to do |format|
      if @bed_order.update(bed_order_params)
        format.html { redirect_to @bed_order, notice: 'Bed order was successfully updated.' }
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
    @bed_order.destroy
    respond_to do |format|
      format.html { redirect_to bed_orders_url, notice: 'Bed order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bed_order
      @bed_order = BedOrder.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bed_order_params
      params.require(:bed_order).permit(:status, :remit_code, :created_by_id, :audited_by_id, :sent_dy, :received_by_id, :sent_request_by_id_id, :sent_date, :deleted_at, :date_received, :patient_id)
    end
end
