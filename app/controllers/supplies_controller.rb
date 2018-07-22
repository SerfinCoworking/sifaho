class SuppliesController < ApplicationController
  before_action :set_supply, only: [:show, :edit, :update, :destroy]

  # GET /supplies
  # GET /supplies.json
  def index
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
        :search_query,
        :with_code,
        :with_area_id,
      ],
    ) or return
    @supplies = @filterrific.find.page(params[:page]).per_page(8)
    @supply_areas = SupplyArea.all

    respond_to do |format|
      format.html
      format.js
    end
    rescue ActiveRecord::RecordNotFound => e
      # There is an issue with the persisted param_set. Reset it.
      puts "Had to reset filterrific params: #{ e.message }"
      redirect_to(reset_filterrific_url(format: :html)) and return
  end

  # GET /supplies/1
  # GET /supplies/1.json
  def show
    _percent = @supply.quantity.to_f / @supply.initial_quantity  * 100 unless @supply.initial_quantity == 0
    @percent_quantity_supply = _percent

    respond_to do |format|
      format.js
    end
  end

  # GET /supplies/new
  def new
    @supply = Supply.new
  end

  # GET /supplies/1/edit
  def edit
  end

  # POST /supplies
  # POST /supplies.json
  def create
    @supply = Supply.new(supply_params)
    @new_supply_lot = Supply.new

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
    @supply_name = @supply.name
    @supply.destroy
    respond_to do |format|
      flash.now[:success] = "El suministro "+@supply_name+" se ha eliminado correctamente."
      format.js
    end
  end

  def search_by_name
    @supplies = Supply.order(:name).search_query(params[:term]).limit(15)
    render json: @supplies.map{ |sup| { label: sup.name, id: sup.id, expiry: sup.needs_expiration } }
  end

  def search_by_id
    @supplies = Supply.order(:id).with_code(params[:term])
    render json: @supplies.map{ |sup| { label: sup.id, name: sup.name , expiry: sup.needs_expiration } }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_supply
      @supply = Supply.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def supply_params
      params.require(:supply).permit(:name, :quantity, :expiry_date, :date_received)
    end
end
