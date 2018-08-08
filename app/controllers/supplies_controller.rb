class SuppliesController < ApplicationController
  before_action :set_supply, only: [:show, :edit, :update, :destroy, :delete, :restore, :restore_confirm]

  # GET /supplies
  # GET /supplies.json
  def index
    authorize Supply
    @filterrific = initialize_filterrific(
      Supply,
      params[:filterrific],
      select_options: {
        sorted_by: Supply.options_for_sorted_by
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'codigo_asc'},
      available_filters: [
        :sorted_by,
        :search_text,
        :with_code,
        :with_area_id,
      ],
    ) or return
    @supplies = @filterrific.find.page(params[:page]).per_page(8)
    @supply_areas = SupplyArea.all
  end

  # GET /supplies
  # GET /supplies.json
  def trash_index
    authorize Supply
    @filterrific = initialize_filterrific(
      Supply.only_deleted,
      params[:filterrific],
      select_options: {
        sorted_by: Supply.options_for_sorted_by
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'codigo_asc'},
      available_filters: [
        :sorted_by,
        :search_text,
        :with_code,
        :with_area_id,
      ],
    ) or return
    @supplies = @filterrific.find.page(params[:page]).per_page(8)
    @supply_areas = SupplyArea.all
  end

  # GET /supplies/1
  # GET /supplies/1.json
  def show
    authorize @supply
    respond_to do |format|
      format.js
    end
  end

  # GET /supplies/new
  def new
    authorize Supply
    @supply = Supply.new
    @unities = Unity.all
    @supply_areas = SupplyArea.all
  end

  # GET /supplies/1/edit
  def edit
    authorize @supply
    @unities = Unity.all
    @supply_areas = SupplyArea.all
  end

  # POST /supplies
  # POST /supplies.json
  def create
    @supply = Supply.new(supply_params)
    @new_supply_lot = Supply.new
    authorize @supply

    respond_to do |format|
      if @supply.save
        flash.now[:success] = "El suministro "+@supply.name+" se ha creado correctamente."
        format.js
      else
        flash.now[:error] = "El suministro no se ha podido crear."
        format.js
      end
    end
  end

  # PATCH/PUT /supplies/1
  # PATCH/PUT /supplies/1.json
  def update
    authorize @supply
    respond_to do |format|
      if @supply.update(supply_params)
        flash.now[:success] = "El suministro "+@supply.name+" se ha modificado correctamente."
        format.js
      else
        flash.now[:error] = "El suministro "+@supply.name+" no se ha podido modificar."
        format.js
      end
    end
  end

  # DELETE /supplies/1
  # DELETE /supplies/1.json
  def destroy
    authorize @supply
    @supply_name = @supply.name
    @supply.destroy
    respond_to do |format|
      flash.now[:success] = "El suministro "+@supply_name+" se ha eliminado correctamente."
      format.js
    end
  end

  # GET /supply/1/delete
  def delete
    authorize @supply
    respond_to do |format|
      format.js
    end
  end

  # GET /supply/1/restore_confirm
  def restore_confirm
    respond_to do |format|
      format.js
    end
  end

  # GET /supply/1/restore
  def restore
    authorize @supply
    Supply.restore(@supply.id, :recursive => true)

    respond_to do |format|
      flash.now[:success] = "El insumo código "+@supply.id.to_s+" se ha restaurado correctamente."
      format.js
    end
  end

  def search_by_name
    @supplies = Supply.order(:name).search_text(params[:term]).limit(15)
    render json: @supplies.map{ |sup| { label: sup.name, id: sup.id, expiry: sup.needs_expiration } }
  end

  def search_by_id
    @supplies = Supply.order(:id).with_code(params[:term]).limit(8)
    render json: @supplies.map{ |sup| { label: sup.id.to_s+" "+sup.name, value: sup.id, name: sup.name , expiry: sup.needs_expiration } }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_supply
      @supply = Supply.with_deleted.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def supply_params
      params.require(:supply).permit(:name, :period_alarm, :period_control, :expiration_alarm,
                                     :is_active, :needs_expiration, :unity, :supply_area_id,
                                     :description, :observation, :active_alarm, :quantity_alarm)
    end
end
