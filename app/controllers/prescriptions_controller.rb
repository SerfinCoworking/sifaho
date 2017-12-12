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
    @quantity_medication = QuantityMedication.new
  end

  # GET /prescriptions/1/edit
  def edit
  end

  # POST /prescriptions
  # POST /prescriptions.json
  def create
    @prescription = Prescription.new(prescription_params)
    @quan_med = QuantityMedication.new(params[:quantity_medications_attributes])
    @quan_med.medication = Medication.find_by_id(params[:quantity_medication][:medication])
    @quan_med.quantity = params[:quantity_medication][:quantity]

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

    # Never trust parameters from the scary internet, only allow the white list through.
    def prescription_params
      params.require(:prescription).permit(:observation, :date_received, :date_processed,
                                           :professional_id, :patient_id, :prescription_status_id,
                                           quantity_medications_attributes: [:medication, :quantity])
    end
end
