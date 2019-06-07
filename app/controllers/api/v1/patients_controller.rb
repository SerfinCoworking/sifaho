module Api::V1
  class PatientsController < ApiController
    skip_before_action :verify_authenticity_token
    
    # GET /v1/patients
    def index
      patients = Patient.all
      render json: patients, status: :ok
    end

    def show
      patient = Patient.find(params[:id])
      render json: patient, status: :ok
    end

    def create
      patient = Patient.new(patient_params)
      if patient.save
        render json: patient, status: :created
      else
        render json: { errors: patient.errors }, status: :unprocessable_entity
      end
    end

    def update
      patient = Patient.find(params[:id])
      if patient.update(patient_params)
        render json: patient, status: :ok
      else
        render json: { errors: patient.errors }, status: :unprocessable_entity
      end
    end

    private
  
    def patient_params
      params.require(:patient).permit(:dni, :first_name, :last_name, :birthdate, :patient_type)
    end
  end
end