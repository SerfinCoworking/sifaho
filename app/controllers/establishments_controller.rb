class EstablishmentsController < ApplicationController
  before_action :set_establishment, only: [:show, :edit, :update, :destroy, :delete]

  # GET /establishments
  # GET /establishments.json
  def index
    @filterrific = initialize_filterrific(
      Establishment,
      params[:filterrific],
      select_options: {
        sorted_by: Establishment.options_for_sorted_by,
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'created_at_desc'},
      available_filters: [
        :sorted_by,
        :search_fullname,
        :search_dni,
        :with_patient_type_id,
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
    @patient = Patient.new
  end

  # GET /establishments/1/edit
  def edit
  end

  # POST /establishments
  # POST /establishments.json
  def create
    @patient = Patient.new(establishment_params)

    respond_to do |format|
      if @patient.save
        flash.now[:success] = @patient.full_info+" se ha creado correctamente."
        format.html { redirect_to @patient }
        format.js
      else
        flash[:error] = "El paciente no se ha podido crear."
        format.html { render :new }
        format.js { render layout: false, content_type: 'text/javascript' }
      end
    end
  end

  # PATCH/PUT /establishments/1
  # PATCH/PUT /establishments/1.json
  def update
    respond_to do |format|
      if @patient.update(establishment_params)
        flash.now[:success] = @patient.full_info+" se ha modificado correctamente."
        format.js
      else
        flash.now[:error] = @patient.full_info+" no se ha podido modificar."
        format.js
      end
    end
  end

  # DELETE /establishments/1
  # DELETE /establishments/1.json
  def destroy
    @full_info = @patient.full_info
    @patient.destroy
    respond_to do |format|
      flash.now[:success] = "El paciente "+@full_info+" se ha eliminado correctamente."
      format.js
    end
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
    params.require(:establishment).permit(:first_name, :last_name, :dni,
      :email, :birthdate, :sex, :marital_status,
      establishment_phones_attributes: [:id, :phone_type, :number, :_destroy])
  end
end
