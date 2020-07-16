class PatientsController < ApplicationController
  before_action :set_patient, only: [:show, :edit, :update, :destroy, :delete]

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
        :search_fullname,
        :search_dni,
        :with_patient_type_id,
      ],
    ) or return
    @patients = @filterrific.find.page(params[:page]).per_page(15)
  end

  # GET /patients/1
  # GET /patients/1.json
  def show
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /patients/new
  def new
    @patient = Patient.new
    @patient_types = PatientType.all
    @patient.patient_phones.build
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

  # PATCH/PUT /patients/1
  # PATCH/PUT /patients/1.json
  def update
    respond_to do |format|
      if @patient.update(patient_params)
        flash.now[:success] = @patient.full_info+" se ha modificado correctamente."
        format.js
      else
        flash.now[:error] = @patient.full_info+" no se ha podido modificar."
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

  # GET /patient/1/delete
  def delete
    respond_to do |format|
      format.js
    end
  end

  def search
    @patients = Patient.order(:first_name).search_query(params[:term]).limit(10)
    render json: @patients.map{ |pat| { id: pat.id, dni: pat.dni, label: pat.fullname } }
  end

  def get_by_dni_and_fullname
    @patients = Patient.get_by_dni_and_fullname(params[:term]).limit(10).order(:last_name)
    render json: @patients.map{ |pat| { id: pat.id, label: pat.dni.to_s+" "+pat.last_name+" "+pat.first_name, dni: pat.dni }  }
  end

  def get_by_dni
    @patients = Patient.search_dni(params[:term])
    render json: @patients.map{ |pat| { id: pat.id, label: pat.dni.to_s+" "+pat.last_name+" "+pat.first_name, dni: pat.dni, fullname: pat.fullname }  }
  end

  def get_by_fullname
    @patients = Patient.search_fullname(params[:term]).limit(10).order(:last_name)
    render json: @patients.map{ |pat| { id: pat.id, label: pat.dni.to_s+" "+pat.fullname, dni: pat.dni, fullname: pat.fullname  }  }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_patient
      @patient = Patient.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def patient_params
      params.require(:patient).permit(:first_name, :last_name, :dni,
        :email, :birthdate, :sex, :marital_status,
        patient_phones_attributes: [:id, :phone_type, :number, :_destroy])
    end
end
