class LotsController < ApplicationController
  before_action :set_lot, only: [:show, :edit, :update, :destroy]

  # GET /lots
  # GET /lots.json
  def index
    authorize Lot
    @filterrific = initialize_filterrific(
      Lot,
      params[:filterrific],
      persistence_id: false,
    ) or return
    @lots = @filterrific.find.paginate(page: params[:page], per_page: 15)
  end

  # GET /lots/1
  # GET /lots/1.json
  def show
    authorize @lot
  end

  # GET /lots/new
  def new
    authorize Lot
    @lot = Lot.new
    @laboratories = Laboratory.all
  end

  # GET /lots/1/edit
  def edit
    authorize @lot
    @laboratories = Laboratory.all
  end

  # POST /lots
  # POST /lots.json
  def create
    @lot = Lot.new(lot_params)

    respond_to do |format|
      if @lot.save
        format.html { redirect_to @lot, notice: 'Lot was successfully created.' }
        format.json { render :show, status: :created, location: @lot }
      else
        format.html { render :new }
        format.json { render json: @lot.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lots/1
  # PATCH/PUT /lots/1.json
  def update
    authorize @lot

    respond_to do |format|
      if @lot.update(lot_params)
        format.html { redirect_to @lot, notice: 'Lot was successfully updated.' }
        format.json { render :show, status: :ok, location: @lot }
      else
        format.html { render :edit }
        format.json { render json: @lot.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lots/1
  # DELETE /lots/1.json
  def destroy
    authorize @lot
    @lot.destroy
    respond_to do |format|
      format.html { redirect_to lots_url, notice: 'Lot was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search_by_code
    if params[:product_code].present?
      @lots = Lot.order(:code).with_product_code(params[:product_code]).search_lot_code(params[:term]).limit(10)
    else
      @lots = Lot.order(:code).search_lot_code(params[:term]).limit(10)
    end

    render json: @lots.map{ |lot| 
      { 
        label: lot.code+" | "+lot.laboratory.name,
        value: lot.code,
        expiry_date: lot.expiry_date,
        lab_name: lot.laboratory.name,
        lab_id: lot.laboratory_id 
      } 
    }  
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lot
      @lot = Lot.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def lot_params
      params.require(:lot).permit(:product_id, :laboratory_id, :code, :expiry_date)
    end
end
