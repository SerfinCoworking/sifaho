class InpatientPrescriptionsController < ApplicationController
  include FindLots
  before_action :set_inpatient_prescription, only: [:show, :edit, :update, :destroy, :delivery, :update_with_delivery, :set_products]
  before_action :set_hospitalized_patients, only: %i[index new edit create]

  # GET /inpatient_prescriptions
  # GET /inpatient_prescriptions.json
  def index
    @filterrific = initialize_filterrific(
      InpatientPrescription,
      params[:filterrific],
      select_options: {
        sorted_by: InpatientPrescription.options_for_sorted_by,
        for_statuses: InpatientPrescription.options_for_status
      },
      persistence_id: false
    ) or return
    @inpatient_prescriptions = @filterrific.find.paginate(page: params[:page], per_page: 15)
  end

  # GET /inpatient_prescriptions/1
  # GET /inpatient_prescriptions/1.json
  def show
  end

  # GET /inpatient_prescriptions/1
  # GET /inpatient_prescriptions/1.json
  def set_products
    authorize @inpatient_prescription
    @inpatient_prescription.parent_order_products.build
  end

  # GET /inpatient_prescriptions/new
  def new
    @inpatient_prescription = InpatientPrescription.new
    @inpatient_prescription.parent_order_products.build
  end

  # GET /inpatient_prescriptions/1/edit
  def edit
  end

  # POST /inpatient_prescriptions
  # POST /inpatient_prescriptions.json
  def create
    authorize @inpatient_prescription
    respond_to do |format|
      @inpatient_prescription = InpatientPrescription.new(inpatient_prescription_params)
      @inpatient_prescription.prescribed_by = current_user
      if @inpatient_prescription.save
        @inpatient_prescription.create_notification(current_user, 'creó')
        message = "La receta de internación de #{@inpatient_prescription.patient.fullname} se ha creado correctamente."
        format.html { redirect_to set_products_inpatient_prescriptions_path(@inpatient_prescription), notice: message }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /inpatient_prescriptions/1
  # PATCH/PUT /inpatient_prescriptions/1.json
  def update
    authorize @inpatient_prescription
    respond_to do |format|
      if @inpatient_prescription.update(inpatient_prescription_params)
        format.html { redirect_to set_products_inpatient_prescriptions_path(@inpatient_prescription), notice: 'Inpatient prescription was successfully updated.' }
        format.json { render :show, status: :ok, location: @inpatient_prescription }
      else
        format.html { render :edit }
        format.json { render json: @inpatient_prescription.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /inpatient_prescriptions/1
  # DELETE /inpatient_prescriptions/1.json
  def destroy
    authorize @inpatient_prescription
    @professional_fullname = @inpatient_prescription.prescribed_by.professional.fullname
    @inpatient_prescription.destroy
    respond_to do |format|
      flash.now[:success] = "La receta de #{@professional_fullname} se ha eliminado correctamente."
      format.js
    end
  end

  # DELIVERY /inpatient_prescriptions/1
  # DELIVERY /inpatient_prescriptions/1.json
  def delivery
    authorize @inpatient_prescription
  end

  def update_with_delivery
    @inpatient_prescription.dispensed_by(current_user)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_inpatient_prescription
    @inpatient_prescription = InpatientPrescription.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def inpatient_prescription_params
    params.require(:inpatient_prescription).permit(
      :patient_id,
      :date_prescribed,
      :observation
    )
  end

  def set_hospitalized_patients
    @inpatients = current_user.establishment.hospitalized_patients
  end
end
