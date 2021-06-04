class InpatientPrescriptionsController < ApplicationController
  
  include FindLots
  before_action :set_inpatient_prescription, only: [:show, :edit, :update, :destroy, :delivery, :update_with_delivery]

  # GET /inpatient_prescriptions
  # GET /inpatient_prescriptions.json
  def index
    @inpatient_prescriptions = InpatientPrescription.all
  end

  # GET /inpatient_prescriptions/1
  # GET /inpatient_prescriptions/1.json
  def show
  end

  # GET /inpatient_prescriptions/new
  def new
    @inpatient_prescription = InpatientPrescription.new
    @inpatient_prescription.order_products.build
    @inpatients = Patient.all.limit(10)
  end

  # GET /inpatient_prescriptions/1/edit
  def edit
    @inpatients = Patient.all.limit(10)
  end

  # POST /inpatient_prescriptions
  # POST /inpatient_prescriptions.json
  def create
    @inpatient_prescription = InpatientPrescription.new(inpatient_prescription_params)
    @inpatient_prescription.remit_code = "IN#{DateTime.now.to_s(:number)}"
    @inpatient_prescription.status = 'pendiente'

    respond_to do |format|
      @inpatient_prescription.save!
      begin
        # if(dispensing?); @inpatient_prescription.dispense_by(current_user); end

        message = "La receta de internación de #{@inpatient_prescription.patient.fullname} se ha creado correctamente."
        notification_type = 'creó'

        @inpatient_prescription.create_notification(current_user, notification_type)
        format.html { redirect_to delivery_inpatient_prescriptions_path(@inpatient_prescription), notice: message }
      rescue ArgumentError => e
        # si fallo la validacion de stock debemos modificar el estado a proveedor_auditoria
        flash[:error] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @inpatient_prescription.order_products || @inpatient_prescription.order_products.build
        @inpatients = Patient.all.limit(10)
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /inpatient_prescriptions/1
  # PATCH/PUT /inpatient_prescriptions/1.json
  def update
    respond_to do |format|
      if @inpatient_prescription.update(inpatient_prescription_params)
        format.html { redirect_to delivery_inpatient_prescriptions_path(@inpatient_prescription), notice: 'Inpatient prescription was successfully updated.' }
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
    @professional_fullname = @inpatient_prescription.professional.fullname
    @inpatient_prescription.destroy
    respond_to do |format|
      flash.now[:success] = "La receta de #{@professional_fullname} se ha eliminado correctamente."
      format.js
    end
  end

  # DELIVERY /inpatient_prescriptions/1
  # DELIVERY /inpatient_prescriptions/1.json
  def delivery
  end

  # UPDATE_WITH_DELIVERY /inpatient_prescriptions/1
  # UPDATE_WITH_DELIVERY /inpatient_prescriptions/1.json
  def update_with_delivery
    respond_to do |format|
      begin
        @inpatient_prescription.dispensed_by(current_user)
        message = "La receta de internación de #{@inpatient_prescription.patient.fullname} se ha entregado correctamente."
        format.html { redirect_to @inpatient_prescription, notice: message }
      rescue ArgumentError => e
        flash[:error] = e.message
      ensure
        format.html { render :delivery }
      end
    end
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
      :professional_id,
      :bed_id,
      :remit_code,
      :observation,
      :status,
      :date_prescribed,
      order_products_attributes: [
        :id,
        :product_id,
        :dose_quantity,
        :interval,
        :dose_total,
        :status,
        :observation,
        :_destroy
      ]
    )
  end

  def inpatient_prescription_lots_params
    params.require(:inpatient_prescription).permit(
      original_order_products_attributes: [
        :id,
        children_attributes: [
          :product_id,
          :dose_total,
          :observation
        ]
      ]
    )
  end

  def dispensing?
    return params[:commit] == "dispensing"
  end
end
