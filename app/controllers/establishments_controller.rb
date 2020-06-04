class EstablishmentsController < ApplicationController
  before_action :set_establishment, only: [:show, :edit, :update, :destroy, :delete]

  # GET /establishments
  # GET /establishments.json
  def index
    @filterrific = initialize_filterrific(
      Establishment,
      params[:filterrific],
      persistence_id: false,
      available_filters: [
        :sorted_by,
        :search_name,
      ],
    ) or return
    @establishments = @filterrific.find.page(params[:page]).per_page(15)
  end

  # GET /establishments/1
  # GET /establishments/1.json
  def show
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /establishments/new
  def new
    @establishment = Establishment.new
  end

  # GET /establishments/1/edit
  def edit
  end

  # POST /establishments
  # POST /establishments.json
  def create
    @establishment = Establishment.new(establishment_params)

    respond_to do |format|
      if @establishment.save
        flash.now[:success] = @establishment.name + " se ha creado correctamente."
        format.html { redirect_to @establishment }
        format.js
      else
        flash[:error] = "El establecimiento no se ha podido crear."
        format.html { render :new }
        format.js { render layout: false, content_type: 'text/javascript' }
      end
    end
  end

  # PATCH/PUT /establishments/1
  # PATCH/PUT /establishments/1.json
  def update
    respond_to do |format|
      if @establishment.update(establishment_params)
        flash.now[:success] = @establishment.name + " se ha modificado correctamente."
        format.html { redirect_to @establishment }
        format.js
      else
        flash.now[:error] = @establishment.name + " no se ha podido modificar."
        format.html { render :edit }
        format.js
      end
    end
  end

  # DELETE /establishments/1
  # DELETE /establishments/1.json
  def destroy
    # establishment_name = @establishment.name
    # @establishment.destroy
    # respond_to do |format|
    #   flash.now[:success] = "El establecimiento "+establishment_name+" se ha eliminado correctamente."
    #   format.js
    # end
  end

  # GET /establishment/1/delete
  def delete
    respond_to do |format|
      format.js
    end
  end

  def search_by_name
    @establishments = Establishment.order(:name).search_name(params[:term]).limit(10).where_not_id(current_user.sector.establishment_id)
    render json: @establishments.map{ |est| { label: est.name, id: est.id } }
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_establishment
    @establishment = Establishment.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def establishment_params
    params.require(:establishment).permit(
      :code,
      :name,
      :cuit,
      :email,
      :sectors_count,
      :domicile,
      :phone
    )
  end
end
