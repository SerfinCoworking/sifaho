class LotProvenancesController < ApplicationController
  before_action :set_lot_provenance, only: [:show, :edit, :update, :destroy]

  # GET /lot_provenances
  # GET /lot_provenances.json
  def index
    authorize LotProvenance
    @lot_provenances = LotProvenance.all
  end

  # GET /lot_provenances/1
  # GET /lot_provenances/1.json
  def show
    authorize @lot_provenance
  end

  # GET /lot_provenances/new
  def new
    authorize LotProvenance
    @lot_provenance = LotProvenance.new
    @laboratories = Laboratory.all
  end

  # GET /lot_provenances/1/edit
  def edit
    authorize @lot_provenance
    @laboratories = Laboratory.all
  end

  # POST /lot_provenances
  # POST /lot_provenances.json
  def create
    @lot_provenance = LotProvenance.new(lot_provenance_params)

    respond_to do |format|
      if @lot_provenance.save
        format.html { redirect_to @lot_provenance, notice: 'LotProvenance was successfully created.' }
        format.js { render :create, flash.now[:notice] = "Here is my flash notice" }
      else
        format.js { render :new }
        format.json { render json: @lot_provenance.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lot_provenances/1
  # PATCH/PUT /lot_provenances/1.json
  def update
    authorize @lot_provenance

    respond_to do |format|
      if @lot_provenance.update(lot_provenance_params)
        format.html { redirect_to @lot_provenance, notice: 'LotProvenance was successfully updated.' }
        format.json { render :show, status: :ok, location: @lot_provenance }
      else
        format.html { render :edit }
        format.json { render json: @lot_provenance.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lot_provenances/1
  # DELETE /lot_provenances/1.json
  def destroy
    authorize @lot_provenance
    @lot_provenance.destroy
    respond_to do |format|
      format.html { redirect_to lot_provenances_url, notice: 'LotProvenance was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lot_provenance
      @lot_provenance = LotProvenance.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def lot_provenance_params
      params.require(:lot_provenance).permit(:name)
    end  
end
