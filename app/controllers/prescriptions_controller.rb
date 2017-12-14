class PrescriptionsController < ApplicationController
  before_action :set_prescription, only: [:show, :edit, :update, :destroy]

  # GET /prescriptions
  # GET /prescriptions.json
  def index
    @prescriptions = Prescription.all
  end

  # GET /prescriptions/1
  # GET /prescriptions/1.json
  def show
  end

  # GET /prescriptions/new
  def new
    @prescription = Prescription.new
    @professionals = Professional.all
    @professional = Professional.new
    @medications = Medication.all
    @patients = Patient.all
    @patient = Patient.new
    @patient_types = PatientType.all
    @quantity_medication = QuantityMedication.new
  end

  # GET /prescriptions/1/edit
  def edit
  end

  # POST /prescriptions
  # POST /prescriptions.json
  def create
    @prescription = Prescription.new(prescription_params)
    if(params[:prescription][:patient_id].blank?)
      @patient = Patient.create!(patient_params)
      @prescription.patient_id = @patient.id
    end
    if(params[:prescription][:professional_id].blank?)
      @professional = Professional.create!(professional_params)
      @prescription.professional_id = @professional.id
    end
    @quan_med = QuantityMedication.new(quantity_medication_params)

    respond_to do |format|
      if @prescription.save
        @quan_med.quantifiable = @prescription
        if @quan_med.save!
          format.html { redirect_to @prescription, notice: 'La Prescripción se ha creado correctamente.' }
          format.json { render :show, status: :created, location: @prescription }
        else
          format.html { render :new }
          format.json { render json: @prescription.errors, status: :unprocessable_entity }
        end
      else
        format.html { render :new }
        format.json { render json: @prescription.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /prescriptions/1
  # PATCH/PUT /prescriptions/1.json
  def update
    respond_to do |format|
      if @prescription.update(prescription_params)
        format.html { redirect_to @prescription, notice: 'La Prescripción se ha modificado correctamente.' }
        format.json { render :show, status: :ok, location: @prescription }
      else
        format.html { render :edit }
        format.json { render json: @prescription.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /prescriptions/1
  # DELETE /prescriptions/1.json
  def destroy
    @prescription.destroy
    respond_to do |format|
      format.html { redirect_to prescriptions_url, notice: 'La Prescripción se ha eliminado correctamente.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_prescription
      @prescription = Prescription.find(params[:id])
    end

    def professional_params
      params.require(:professional).permit(:first_name, :last_name, :dni)
    end

    def patient_params
      params.require(:patient).permit(:first_name, :last_name, :dni, :patient_type_id)
    end

    def quantity_medication_params
      params.require(:quantity_medication).permit(:medication_id, :quantity)
    end

    def prescription_params
      params.require(:prescription).permit(:observation, :date_received, :date_processed,
                                           :professional_id, :patient_id, :prescription_status_id)
    end
end
