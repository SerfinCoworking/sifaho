class PatientsController < ApplicationController
  before_action :set_patient, only: [:show, :edit, :update, :destroy]

  # GET /patients
  # GET /patients.json
  def index
    @filterrific = initialize_filterrific(
      Patient,
      params[:filterrific],
      select_options: {
        sorted_by: Patient.options_for_sorted_by,
        with_patient_type_id: PatientType.options_for_select
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'created_at_desc'},
      available_filters: [
        :sorted_by,
        :search_query,
        :search_dni,
        :with_patient_type_id,
      ],
    ) or return
    @patients = @filterrific.find.page(params[:page]).per_page(8)


    respond_to do |format|
      format.html
      format.js
    end
    rescue ActiveRecord::RecordNotFound => e
      # There is an issue with the persisted param_set. Reset it.
      puts "Had to reset filterrific params: #{ e.message }"
      redirect_to(reset_filterrific_url(format: :html)) and return
  end

  # GET /patients/1
  # GET /patients/1.json
  def show
    respond_to do |format|
      format.js
    end
  end

  # GET /patients/new
  def new
    @patient = Patient.new
    @patient.build_patient_type
    @patient_types = PatientType.all
  end

  # GET /patients/1/edit
  def edit
    @patient_types = PatientType.all
  end

  # POST /patients
  # POST /patients.json
  def create
    @patient = Patient.new(patient_params)

    respond_to do |format|
      if @patient.save
        flash.now[:success] = "El paciente "+@patient.first_name+" se ha creado correctamente."
        format.js
      else
        flash.now[:error] = "El paciente no se ha podido crear."
        format.js
      end
    end
  end

  # PATCH/PUT /patients/1
  # PATCH/PUT /patients/1.json
  def update
    respond_to do |format|
      if @patient.update(patient_params)
        flash.now[:success] = "El paciente se ha modificado correctamente."
        format.js
      else
        flash.now[:error] = "El paciente no se ha podido modificar."
        format.js
      end
    end
  end

  # DELETE /patients/1
  # DELETE /patients/1.json
  def destroy
    @full_info = @patient.full_info
    @patient.destroy
    respond_to do |format|
      flash.now[:success] = "El paciente "+@full_info+" se ha eliminado correctamente."
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_patient
      @patient = Patient.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def patient_params
      params.require(:patient).permit(:first_name, :last_name, :dni,
                            :address, :email, :phone,
                            patient_type_attributes: [:id, :sector_name, :quantity,
                                                :complexity_level, :description])
    end
end
