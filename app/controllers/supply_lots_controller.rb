class SupplyLotsController < ApplicationController
  before_action :set_supply_lot, only: [:show, :edit, :update, :destroy, :delete, :restore, :restore_confirm]

  # GET /supply_lots
  # GET /supply_lots.json
  def index
    authorize SupplyLot
    @filterrific = initialize_filterrific(
      SupplyLot.lots_for_sector(current_user.sector),
      params[:filterrific],
      select_options: {
        sorted_by: SupplyLot.options_for_sorted_by,
        with_status: SupplyLot.options_for_status
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'creacion_desc'},
      available_filters: [
        :sorted_by,
        :with_status,
        :search_text,
        :with_code,
        :with_area_id,
        :date_received_at
      ],
    ) or return
    @supply_lots = @filterrific.find.page(params[:page]).per_page(8)

    @new_supply_lot = SupplyLot.new

    rescue ActiveRecord::RecordNotFound => e
      # There is an issue with the persisted param_set. Reset it.
      puts "Had to reset filterrific params: #{ e.message }"
      redirect_to(reset_filterrific_url(format: :html)) and return
  end

  def trash_index
    authorize SupplyLot
    @filterrific = initialize_filterrific(
      SupplyLot.only_deleted.lots_for_sector(current_user.sector),
      params[:filterrific],
      select_options: {
        sorted_by: SupplyLot.options_for_sorted_by,
        with_status: SupplyLot.options_for_status
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'creacion_desc'},
      available_filters: [
        :sorted_by, :with_status, :search_text, :with_code, :with_area_id,
        :date_received_at
      ],
    ) or return
    @supply_lots = @filterrific.find.page(params[:page]).per_page(8)

    rescue ActiveRecord::RecordNotFound => e
      # There is an issue with the persisted param_set. Reset it.
      puts "Had to reset filterrific params: #{ e.message }"
      redirect_to(reset_filterrific_url(format: :html)) and return
  end


  # GET /supply_lots/1
  # GET /supply_lots/1.json
  def show
    authorize @supply_lot
    _percent = @supply_lot.quantity.to_f / @supply_lot.initial_quantity  * 100 unless @supply_lot.initial_quantity == 0
    @percent_quantity_supply_lot = _percent

    respond_to do |format|
      format.js
    end
  end

  # GET /supply_lots/new
  def new
    authorize SupplyLot
    @supply_lot = SupplyLot.new
  end

  # GET /supply_lots/1/edit
  def edit
    authorize @supply_lot
    @new_supply_lot = @supply_lot
  end

  # POST /supply_lots
  # POST /supply_lots.json
  def create
    @supply_lot = SupplyLot.new(supply_lot_params)
    @supply_lot.sector = current_user.sector
    authorize @supply_lot

    respond_to do |format|
      if @supply_lot.save!
        flash.now[:success] = "El lote de "+@supply_lot.supply_name+" se ha creado correctamente."
        format.js
      else
        flash.now[:error] = "El lote no se ha podido crear."
        format.js
      end
    end
  end

  # PATCH/PUT /supply_lots/1
  # PATCH/PUT /supply_lots/1.json
  def update
    authorize @supply_lot

    respond_to do |format|
      if @supply_lot.update(supply_lot_params)
        flash.now[:success] = "El lote de "+@supply_lot.supply_name+" se ha modificado correctamente."
        format.js
      else
        flash.now[:error] = "El lote de "+@supply_lot.supply_name+" no se ha podido modificar."
        format.js
      end
    end
  end

  # DELETE /supply_lots/1
  # DELETE /supply_lots/1.json
  def destroy
    authorize @supply_lot
    @supply_name = @supply_lot.supply_name
    @supply_lot.destroy
    respond_to do |format|
      flash.now[:success] = "El lote de "+@supply_name+" se ha enviado a la papelera."
      format.js
    end
  end

  # GET /supply_lot/1/delete
  def delete
    authorize @supply_lot
    respond_to do |format|
      format.js
    end
  end

  # GET /supply_lot/1/restore_confirm
  def restore_confirm
    respond_to do |format|
      format.js
    end
  end

  # GET /supply_lot/1/restore
  def restore
    authorize @supply_lot
    SupplyLot.restore(@supply_lot.id, :recursive => true)

    respond_to do |format|
      flash.now[:success] = "El lote con código "+@supply_lot.code+" se ha restaurado correctamente."
      format.js
    end
  end

  def search_by_code
    @supply_lots = SupplyLot.lots_for_sector(current_user.sector).order(:code).with_code(params[:term]).limit(10)
    render json: @supply_lots.map{ |sup_lot| { label: sup_lot.code.to_s+" | "+sup_lot.supply_name,
      value: sup_lot.code, id: sup_lot.id, name: sup_lot.supply_name, expiry_date: sup_lot.expiry_date,
      quant: sup_lot.quantity, lot_code: sup_lot.lot_code } }
  end

  def search_by_name
    @supplies = SupplyLot.order(:supply_name).search_text(params[:term]).limit(10)
    render json: @supplies.map{ |sup_lot| { label: sup_lot.supply_name, code: sup_lot.code, id: sup_lot.id,
      quant: sup_lot.quantity, expiry_date: sup_lot.expiry_date, value: sup_lot.supply_name, lot_code: sup_lot.lot_code } }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_supply_lot
      @supply_lot = SupplyLot.with_deleted.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def supply_lot_params
      params.require(:supply_lot).permit(:lot_code, :supply_id, :quantity, :expiry_date, :date_received)
    end
end
