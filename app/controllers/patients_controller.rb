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
    if params[:patient][:address].present?
      @address = set_address(params[:patient][:address])
      @patient.address = @address
    end
    
    patient_photo_res = get_patient_photo_from_andes(params[:patient][:andes_id], params[:patient][:photo_andes_id])
      
    respond_to do |format|
      begin
        file = Tempfile.new(['avatar', '.jpg'], Rails.root.join('tmp'))
        file.binmode
        file.write(patient_photo_res) 
        file.rewind
        @patient.avatar.attach(io: file, filename: "#{params[:patient][:photo_andes_id]}.jpg")
        file.close
        @patient.save!

        # Eliminamos el archivo temporal
        File.delete(file.path) if File.exist?(file.path)

        flash.now[:success] = @patient.full_info+" se ha creado correctamente."
        format.html { redirect_to @patient }
        format.js
      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        format.html { render :new }
        format.js
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
    @patients = Patient.search_dni(params[:term]).order(:dni).limit(15)
    if @patients.present?
      render json: @patients.map{ |pat| {id: pat.id, label: pat.dni.to_s+" "+pat.last_name+" "+pat.first_name,
        dni: pat.dni,
        lastname: pat.last_name,
        firstname: pat.first_name,
        fullname: pat.fullname,
        sex: pat.sex,
        status: pat.status,
        avatar_url: (url_for(pat.avatar) if pat.avatar.attached?)
        }  }
    else
      dni = params[:term]
      token = ENV['ANDES_TOKEN']
      url = ENV['ANDES_MPI_URL']
      andes_patients = RestClient::Request.execute(method: :get, url: "#{url}/search",
        timeout: 30, headers: {
          "Authorization" => "JWT #{token}",
          params: {'documento': dni}
        }
      )
      if JSON.parse(andes_patients).count > 0
        render json: JSON.parse(andes_patients).map{ |pat| 
          patient_photo_res = get_patient_photo_from_andes(pat["_id"], pat["fotoId"])          
          patient_photo = Base64.strict_encode64(patient_photo_res)
          
          patient = { 
            create: true, 
            label: pat['documento'].to_s+" "+pat['apellido']+" "+pat['nombre'], 
            dni: pat['documento'], 
            lastname: pat['apellido'], 
            firstname: pat['nombre'], 
            fullname: pat['apellido']+" "+pat['nombre'], 
            sex: pat["genero"], 
            avatar: patient_photo,
            data: pat  
          }
        }
      else
        render json: [0].map{ |pat| { create: true, dni: params[:term], label: "Agregar paciente" }}
      end
    end
  end

  def get_by_fullname
    @patients = Patient.search_fullname(params[:term]).limit(10).order(:last_name)
    render json: @patients.map{ |pat| { id: pat.id, label: pat.dni.to_s+" "+pat.fullname, dni: pat.dni, fullname: pat.fullname  }  }
  end

  private

    def set_address(address_param)
      # Creamos buscamos o creamos (sino existe) pais / provincia / ciudad
      @country = Country.find_by(name: address_param[:country_name])
      @country = Country.create(name: address_param[:country_name]) unless @country.present?

      @state = State.find_by(name: address_param[:state_name], country_id: @country.id)
      @state = State.create(name: address_param[:state_name], country_id: @country.id) unless @state.present?
      
      @city = City.find_by(name: address_param[:city_name], state_id: @state.id)
      @city = City.create(name: address_param[:city_name], state_id: @state.id) unless @city.present?

      @address = Address.create(postal_code: address_param[:postal_code], 
        line: address_param[:line], 
        city_id: @city.id, 
        country_id: @country.id, 
        state_id: @state.id)

      return @address
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_patient
      @patient = Patient.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def patient_params
      params.require(:patient).permit(
        :first_name,
        :last_name,
        :dni,
        :email,
        :birthdate,
        :sex,
        :marital_status,
        :status,
        :address,
        :andes_id,
        patient_phones_attributes: [
          :id, 
          :phone_type, 
          :number, 
          :_destroy
        ])
    end

    def remote?
      return params[:commit] == "remote"
    end

    def get_patient_photo_from_andes(patient_id, patient_photo_id)
      token = ENV['ANDES_TOKEN']
      url = ENV['ANDES_MPI_URL']
      RestClient::Request.execute(method: :get, url: "#{url}/#{patient_id}/foto/#{patient_photo_id}",
        timeout: 30, headers: {
          "Authorization" => "JWT #{token}",
        }
      )
    end
end
