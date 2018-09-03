class SectorSupplyLotsController < ApplicationController
  before_action :set_sector_supply_lot, only: [:show, :destroy, :delete, :restore,
    :restore_confirm, :purge, :purge_confirm]

  # GET /sector_supply_lots
  # GET /sector_supply_lots.json
  def index
    authorize SectorSupplyLot
    @filterrific = initialize_filterrific(
      SectorSupplyLot.lots_for_sector(current_user.sector),
      params[:filterrific],
      select_options: {
        sorted_by: SectorSupplyLot.options_for_sorted_by,
        with_status: SectorSupplyLot.options_for_status
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'insumo_asc'},
      available_filters: [
        :sorted_by,
        :with_status,
        :search_supply_name,
        :with_code,
        :date_received_at
      ],
    ) or return
    @sector_supply_lots = @filterrific.find.page(params[:page]).per_page(8)

    @new_sector_supply_lot = SectorSupplyLot.new
  end

  def trash_index
    authorize SectorSupplyLot
    @filterrific = initialize_filterrific(
      SectorSupplyLot.only_deleted.lots_for_sector(current_user.sector),
      params[:filterrific],
      select_options: {
        sorted_by: SectorSupplyLot.options_for_sorted_by,
        with_status: SectorSupplyLot.options_for_status
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'recepcion_desc'},
      available_filters: [
        :sorted_by, :with_status, :search_text, :with_code, :date_received_at
      ],
    ) or return
    @sector_supply_lots = @filterrific.find.page(params[:page]).per_page(8)
  end

  # GET /sector_supply_lots/1
  # GET /sector_supply_lots/1.json
  def show
    authorize @sector_supply_lot
    _percent = @sector_supply_lot.quantity.to_f / @sector_supply_lot.initial_quantity  * 100 unless @sector_supply_lot.initial_quantity == 0
    @percent_quantity_sector_supply_lot = _percent

    respond_to do |format|
      format.js
    end
  end

  # POST /supply_lots
  # POST /supply_lots.json
  def create
    @supply_lot = SupplyLot.where(
      lot_code: sector_supply_lot_params[:lot_code],
      laboratory_id: sector_supply_lot_params[:laboratory_id],
      supply_id: sector_supply_lot_params[:supply_id],
    ).first_or_initialize
    @supply_lot.expiry_date = sector_supply_lot_params[:expiry_date]
    @supply_lot.date_received = sector_supply_lot_params[:created_at]

    respond_to do |format|
      begin
        if @supply_lot.save!
          @sector_supply_lot = SectorSupplyLot.where(
            supply_lot_id: @supply_lot.id,
            sector_id: current_user.sector_id,
          ).first_or_initialize
          authorize @sector_supply_lot
          @sector_supply_lot.increment(sector_supply_lot_params[:quantity].to_i)

          if @sector_supply_lot.save!
            flash.now[:success] = "El lote de "+@sector_supply_lot.supply_name+" se ha cargado correctamente."
            format.js
          else
            flash.now[:error] = "El lote no se ha podido cargar."
            format.js
          end
        else
          flash.now[:error] = "El lote provincial no se ha podido crear."
          format.js
        end
      rescue ActiveRecord::RecordInvalid => e
        if e.message == 'Validation failed: Lot code ya está en uso'
          flash.now[:error] = "Ya existe el lote y el insumo no corresponde al mismo."
          format.js
        end
      end
    end
  end

  # DELETE /sector_supply_lots/1
  # DELETE /sector_supply_lots/1.json
  def destroy
    authorize @sector_supply_lot
    @supply_name = @sector_supply_lot.supply_name
    @sector_supply_lot.destroy
    respond_to do |format|
      flash.now[:success] = "El lote de "+@supply_name+" se ha enviado a la papelera."
      format.js
    end
  end

  # GET /supply_lot/1/restore
  def restore
    authorize @sector_supply_lot
    SectorSupplyLot.restore(@sector_supply_lot.id, :recursive => true)

    respond_to do |format|
      flash.now[:success] = "El lote con código "+@sector_supply_lot.code+" se ha restaurado correctamente."
      format.js
    end
  end

  def purge
    authorize @sector_supply_lot
    @code = @sector_supply_lot.code
    @sector_supply_lot.really_destroy!

    respond_to do |format|
      flash.now[:success] = "El lote con código "+@code+" se ha eliminado definitivamente."
      format.js
    end
  end

  def search_by_code
    @sector_supply_lots = SectorSupplyLot.lots_for_sector(current_user.sector).with_code(params[:term]).limit(10).without_status(2).without_status(3)
    render json: @sector_supply_lots.map{ |sup_lot| { label: sup_lot.code.to_s+" | "+sup_lot.supply_name,
      value: sup_lot.code, id: sup_lot.id, name: sup_lot.supply_name, expiry_date: sup_lot.expiry_date,
      quant: sup_lot.quantity, lot_code: sup_lot.lot_code, lab: sup_lot.laboratory, status_label: sup_lot.status_label } }
  end

  def get_with_code
    @sector_supply_lots = SectorSupplyLot.lots_for_sector(current_user.sector).with_code(params[:term]).without_status(2).sorted_by("expiracion_asc")
    render json: @sector_supply_lots.map{ |sup_lot| { label: sup_lot.code.to_s+" | "+sup_lot.supply_name,
      value: sup_lot.code, id: sup_lot.id, name: sup_lot.supply_name, expiry_date: sup_lot.expiry_date,
      quant: sup_lot.quantity, lot_code: sup_lot.lot_code } }
  end

  def search_by_name
    @sector_supply_lots = SectorSupplyLot.lots_for_sector(current_user.sector).search_supply_name(params[:term]).limit(10)
    render json: @sector_supply_lots.map{ |sup_lot| { label: sup_lot.supply_name, code: sup_lot.code, id: sup_lot.id, lab: sup_lot.laboratory,
      quant: sup_lot.quantity, expiry_date: sup_lot.expiry_date, value: sup_lot.supply_name, lot_code: sup_lot.lot_code } }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sector_supply_lot
      @sector_supply_lot = SectorSupplyLot.with_deleted.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sector_supply_lot_params
      params.require(:sector_supply_lot).permit(:quantity, :expiry_date,
        :supply_lot_id, :supply_id, :lot_code, :laboratory_id)
    end
end
