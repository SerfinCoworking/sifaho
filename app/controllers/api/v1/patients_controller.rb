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
      _dni = params[:data][:identifier][0][:value]
      _last_name = params[:data][:name][0][:family]
      _first_name = params[:data][:name][0][:given]
      if is_birthdate_in_params?
        _birthdate = params[:data][:birthDate].to_datetime
      end
      # Create Country, State and City.
      if is_address_in_params?
        _country = Country.where(name: params[:data][:address][0][:country]).first_or_create(name: params[:data][:address][0][:country])
        _state = State.where(name: params[:data][:address][0][:state]).first_or_create(name: params[:data][:address][0][:state], country_id: _country.id)
        _city = City.where(name: params[:data][:address][0][:city]).first_or_create(name: params[:data][:address][0][:city], state_id: _state.id )
      end
      _marital_status = initialize_marital_status
      _gender = initialize_gender
          
      patient = Patient.where(dni: _dni).first_or_initialize(dni: _dni, last_name: _last_name, first_name: _first_name)
      patient.update_attributes(last_name: _last_name, first_name: _first_name, birthdate: _birthdate, marital_status: _marital_status, sex: _gender)
      if is_address_in_params?
        if patient.address.present?
          patient.address.update_attributes(
            postal_code: params[:data][:address][0][:postalCode],
            city_id: _city.id,
            line: params[:data][:address][0][:line][0]
          )
        else
          patient.address = Address.create(
            postal_code: params[:data][:address][0][:postalCode],
            city_id: _city.id,
            line: params[:data][:address][0][:line][0]
          )
        end
      end

      # Update or create the address.
      if patient.save
        patient.Validado!
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
    def is_address_in_params?
      params[:data][:address].present?
    end

    def is_birthdate_in_params?
      params[:data][:birthDate].present?
    end

    def initialize_marital_status
      if params[:data][:maritalStatus].present?
        return case params[:data][:maritalStatus][:text]
        when "unmarried"
          "Soltero"
        when "married"
          "Casado"
        when "legallySeparated"
          "Separado"
        when "divorced"
          "Divorciado"
        when "widowded"
          "Viudo"
        else
          "otro"
        end      
      else
        return "Soltero"
      end
    end

    def initialize_gender
      if params[:data][:gender].present?
        return case params[:data][:gender]
        when "male"
          "Masculino"
        when "female"
          "Femenino"
        else
          "Otro"
        end
      else
        return "Otro"
      end
    end

    def patient_params
      params.require(:active)
            .require(:name)
            .require(:gender)
            .require(:birthdate)
            .require(:maritalStatus)
    end
  end
end