class LaboratoriesController < ApplicationController
  before_action :set_laboratory, only: [:show, :edit, :update, :destroy, :delete]

  # GET /laboratories
  # GET /laboratories.json
  def index
    authorize Laboratory
    @filterrific = initialize_filterrific(
      Laboratory,
      params[:filterrific],
      persistence_id: false,
      default_filter_params: {sorted_by: 'razon_social_asc'},
      available_filters: [
        :search_name,
        :search_cuit,
        :search_gln,
      ],
    ) or return
    @laboratories = @filterrific.find.page(params[:page]).per_page(15)
  end

  # GET /laboratories/1
  # GET /laboratories/1.json
  def show
    authorize @laboratory
    respond_to do |format|
      format.js
    end
  end

  # GET /laboratories/new
  def new
    authorize Laboratory
    @laboratory = Laboratory.new
  end

  # GET /laboratories/1/edit
  def edit
    authorize @laboratory
  end

  # POST /laboratories
  # POST /laboratories.json
  def create
    @laboratory = Laboratory.new(laboratory_params)
    authorize @laboratory

    respond_to do |format|
      if @laboratory.save!
        flash.now[:success] = @laboratory.name+" se ha creado correctamente."
        format.js
      else
        flash.now[:error] = "El laboratorio no se ha podido crear."
        format.js
      end
    end
  end

  # PATCH/PUT /laboratories/1
  # PATCH/PUT /laboratories/1.json
  def update
    authorize @laboratory
    respond_to do |format|
      if @laboratory.update(laboratory_params)
        flash.now[:success] = @laboratory.name+" se ha modificado correctamente."
        format.js
      else
        flash.now[:error] = @laboratory.name+" no se ha podido modificar."
        format.js
      end
    end
  end

  # DELETE /laboratories/1
  # DELETE /laboratories/1.json
  def destroy
    authorize @laboratory
    @name = @laboratory.name
    @laboratory.destroy
    respond_to do |format|
      flash.now[:success] = @name+" se ha enviado a la papelera."
      format.js
    end
  end

  # GET /laboratory/1/delete
  def delete
    authorize @laboratory
    respond_to do |format|
      format.js
    end
  end

  def search_by_name
    @laboratories = Laboratory.order(:name).search_name(params[:term]).limit(10)
    render json: @laboratories.map{ |lab| { label: lab.name, id: lab.id } }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_laboratory
      @laboratory = Laboratory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def laboratory_params
      params.require(:laboratory).permit(:cuit, :gln, :name)
    end
end
