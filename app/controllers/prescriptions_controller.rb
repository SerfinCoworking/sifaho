class PrescriptionsController < ApplicationController
  before_action :set_prescription, only: [:show, :edit, :update, :destroy, :dispense]

  # GET /prescriptions
  # GET /prescriptions.json
  def index
    @filterrific = initialize_filterrific(
      Prescription,
      params[:filterrific],
      select_options: {
        sorted_by: Prescription.options_for_sorted_by
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'created_at_desc'},
      available_filters: [
        :sorted_by,
        :search_query,
        :date_received_at,
      ],
    ) or return
    @prescriptions = @filterrific.find.page(params[:page]).per_page(8)


    respond_to do |format|
      format.html
      format.js
    end
    rescue ActiveRecord::RecordNotFound => e
      # There is an issue with the persisted param_set. Reset it.
      puts "Had to reset filterrific params: #{ e.message }"
      redirect_to(reset_filterrific_url(format: :html)) and return
  end

  # GET /prescriptions/1
  # GET /prescriptions/1.json
  def show
    respond_to do |format|
      format.js
    end
  end

  # GET /prescriptions/new
  def new
    @prescription = Prescription.new
    @sectors = Sector.all
    @patient_types = PatientType.all
    @prescription.build_professional
    @prescription.professional.build_sector
    @prescription.build_patient
    @prescription.quantity_medications.build
    @prescription.quantity_supplies.build
  end

  # GET /prescriptions/1/edit
  def edit
    @professionals = Professional.all
    @medications = Medication.all
    @supplies = Supply.all
    @patients = Patient.all
    @patient_types = PatientType.all
    @sectors = Sector.all
  end

  # POST /prescriptions
  # POST /prescriptions.json
  def create
    @prescription = Prescription.new(prescription_params)

    @prescription.set_pending

    respond_to do |format|
      if @prescription.save!
        dispense if dispensing?
        flash.now[:success] = "La prescripción de "+@prescription.professional.full_name+" se ha creado correctamente."
        format.js
      else
        flash.now[:error] = "La prescripción no se ha podido crear."
        format.js
      end
    end
  end

  # PATCH/PUT /prescriptions/1
  # PATCH/PUT /prescriptions/1.json
  def update
    if dispensing?
      @prescription.dispense
    end

    respond_to do |format|
      if @prescription.update_attributes(prescription_params)
        flash.now[:success] = "La prescripción de "+@prescription.professional.full_name+" se ha modificado correctamente."
        format.js
      else
        flash.now[:error] = "La prescripción de "+@prescription.professional.full_name+" no se ha podido modificar."
        format.js
      end
    end
  end

  # DELETE /prescriptions/1
  # DELETE /prescriptions/1.json
  def destroy
    @professional_full_name = @prescription.professional.full_name
    @prescription.destroy
    respond_to do |format|
      flash.now[:success] = "La prescripción de "+@professional_full_name+" se ha eliminado correctamente."
      format.js
    end
  end

  # GET /prescriptions/1/dispense
  def dispense
    @prescription.dispense

    respond_to do |format|
      if @prescription.save!
        flash.now[:success] = "La prescripción de "+@prescription.professional.full_name+" se ha dispensado correctamente."
        format.js
      else
        flash.now[:error] = "La prescripción no se ha podido dispensar."
        format.js
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_prescription
      @prescription = Prescription.find(params[:id])
    end

    def prescription_params
      params.require(:prescription).permit(
                                             :observation, :date_received, :professional_id, :patient_id, :prescription_status_id,
                                             quantity_medications_attributes: [:id, :medication_id, :quantity, :_destroy],
                                             quantity_supplies_attributes: [:id, :supply_id, :quantity, :_destroy],
                                             patient_attributes: [:id, :first_name, :last_name, :dni, :patient_type_id],
                                             professional_attributes: [:id, :first_name, :last_name, :dni, :enrollment, :sector_id,
                                               sector_attributes: [:id, :sector_name, :description, :complexity_level]
                                             ]
                                          )
    end

    def dispensing?
      submit = params[:commit]
      return submit == "Cargar y dispensar" || submit == "Guardar y dispensar"
    end
end
