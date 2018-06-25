class InternalOrdersController < ApplicationController
  before_action :set_internal_order, only: [:show, :edit, :update, :destroy]

  # GET /internal_orders
  # GET /internal_orders.json
  def index
    @internal_orders = InternalOrder.all
  end

  # GET /internal_orders/1
  # GET /internal_orders/1.json
  def show
  end

  # GET /internal_orders/new
  def new
    @internal_order = InternalOrder.new
  end

  # GET /internal_orders/1/edit
  def edit
  end

  # POST /internal_orders
  # POST /internal_orders.json
  def create
    @internal_order = InternalOrder.new(internal_order_params)

    respond_to do |format|
      if @internal_order.save
        format.html { redirect_to @internal_order, notice: 'Internal order was successfully created.' }
        format.json { render :show, status: :created, location: @internal_order }
      else
        format.html { render :new }
        format.json { render json: @internal_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /internal_orders/1
  # PATCH/PUT /internal_orders/1.json
  def update
    respond_to do |format|
      if @internal_order.update(internal_order_params)
        format.html { redirect_to @internal_order, notice: 'Internal order was successfully updated.' }
        format.json { render :show, status: :ok, location: @internal_order }
      else
        format.html { render :edit }
        format.json { render json: @internal_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /internal_orders/1
  # DELETE /internal_orders/1.json
  def destroy
    @internal_order.destroy
    respond_to do |format|
      format.html { redirect_to internal_orders_url, notice: 'Internal order was successfully destroyed.' }
      format.json { head :no_content }
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
end
