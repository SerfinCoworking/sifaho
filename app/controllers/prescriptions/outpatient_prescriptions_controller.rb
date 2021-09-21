class Prescriptions::OutpatientPrescriptionsController < ApplicationController
  include FindLots

  before_action :set_outpatient_prescription, only: %i[show edit update destroy dispense delete return_dispensation]
  before_action :set_patient_to_outpatient_prescription, only: %i[new create]

  # GET /outpatient_prescriptions
  # GET /outpatient_prescriptions.json
  def index
    authorize OutpatientPrescription
    @filterrific = initialize_filterrific(
      OutpatientPrescription.with_establishment(current_user.establishment),
      params[:filterrific],
      select_options: {
        sorted_by: OutpatientPrescription.options_for_sorted_by,
        for_statuses: OutpatientPrescription.options_for_status
      },
      persistence_id: false
    ) or return
    @outpatient_prescriptions = @filterrific.find.paginate(page: params[:page], per_page: 15)
  end

  # GET /outpatient_prescriptions/1
  # GET /outpatient_prescriptions/1.json
  def show
    authorize @outpatient_prescription

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        pdf = ReportServices::OutpatientPrescriptionReportService.new(current_user, @outpatient_prescription).generate_pdf
        send_data pdf, filename: "Pedido_#{@outpatient_prescription.remit_code}.pdf", type: 'application/pdf', disposition: 'inline'
      end
    end
  end

  # GET /outpatient_prescriptions/new
  def new
    authorize OutpatientPrescription
    @outpatient_prescription.outpatient_prescription_products.build
  end

  # GET /outpatient_prescriptions/1/edit
  def edit
    authorize @outpatient_prescription
  end

  # POST /outpatient_prescriptions
  # POST /outpatient_prescriptions.json
  def create
    authorize @outpatient_prescription
    @outpatient_prescription.provider_sector = current_user.sector
    @outpatient_prescription.establishment = current_user.sector.establishment
    @outpatient_prescription.remit_code = "AM"+DateTime.now.to_s(:number)

    @outpatient_prescription.status = dispensing? ? 'dispensada' : 'pendiente'
    @outpatient_prescription.date_dispensed = dispensing? ? DateTime.now : ''

    respond_to do |format|
      # Si se entrega la receta
      begin
        @outpatient_prescription.save!
        if(dispensing?); @outpatient_prescription.dispense_by(current_user); end

        message = dispensing? ? "La receta ambulatoria de "+@outpatient_prescription.patient.fullname+" se ha creado y dispensado correctamente." : "La receta ambulatoria de "+@outpatient_prescription.patient.fullname+" se ha creado correctamente."
        notification_type = dispensing? ? "creó y dispensó" : "creó"

        @outpatient_prescription.create_notification(current_user, notification_type)
        format.html { redirect_to @outpatient_prescription, notice: message }
      rescue ArgumentError => e
        # si fallo la validacion de stock debemos modificar el estado a proveedor_auditoria
        flash[:error] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @outpatient_prescription_products = @outpatient_prescription.outpatient_prescription_products.present? ? @outpatient_prescription.outpatient_prescription_products : @outpatient_prescription.outpatient_prescription_products.build
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /outpatient_prescriptions/1
  # PATCH/PUT /outpatient_prescriptions/1.json
  def update
    authorize @outpatient_prescription

    @outpatient_prescription.status= dispensing? ? 'dispensada' : 'pendiente'
    @outpatient_prescription.date_dispensed = dispensing? ? DateTime.now : ''

    respond_to do |format|
      begin
        @outpatient_prescription.update!(outpatient_prescription_params)

        if(dispensing?); @outpatient_prescription.dispense_by(current_user); end

        message = dispensing? ? "La receta ambulatoria de "+@outpatient_prescription.patient.fullname+" se ha auditado y dispensado correctamente." : "La receta ambulatoria de "+@outpatient_prescription.patient.fullname+" se ha auditado correctamente."
        notification_type = dispensing? ? "auditó y dispensó" : "auditó"

        @outpatient_prescription.create_notification(current_user, notification_type)
        format.html { redirect_to @outpatient_prescription, notice: message }
      rescue ArgumentError => e
        flash[:error] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @outpatient_prescription_products = @outpatient_prescription.outpatient_prescription_products.present? ? @outpatient_prescription.outpatient_prescription_products : @outpatient_prescription.outpatient_prescription_products.build        
        format.html { render :edit }
      end
    end
  end

  # DELETE /outpatient_prescriptions/1
  # DELETE /outpatient_prescriptions/1.json
  def destroy
    authorize @outpatient_prescription
    @professional_fullname = @outpatient_prescription.professional.fullname
    @outpatient_prescription.destroy
    respond_to do |format|
      flash.now[:success] = "La receta de "+@professional_fullname+" se ha eliminado correctamente."
      format.js
    end
  end

  # GET /outpatient_prescriptions/1/dispense
  def dispense
    authorize @outpatient_prescription
    respond_to do |format|
      begin
        @outpatient_prescription.date_dispensed = DateTime.now
        @outpatient_prescription.dispensada!
        @outpatient_prescription.dispense_by(current_user)
        flash.now[:success] = "La receta de "+@outpatient_prescription.professional.fullname+" se ha dispensado correctamente."
        format.html { redirect_to @outpatient_prescription }
      rescue ArgumentError => e
        flash[:error] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @outpatient_prescription_products = @outpatient_prescription.outpatient_prescription_products.present? ? @outpatient_prescription.outpatient_prescription_products : @outpatient_prescription.outpatient_prescription_products.build        
        format.html { render :edit }
      end
    end
  end

  def return_dispensation
    authorize @outpatient_prescription
    respond_to do |format|
      begin
        @outpatient_prescription.return_dispensation(current_user)
      rescue ArgumentError => e
        flash[:error] = e.message
      else
        flash[:notice] = 'La receta se ha retornado a '+@outpatient_prescription.status+'.'
      end
      format.html { redirect_to @outpatient_prescription }
    end
  end

  def get_by_patient_id
    @outpatient_prescriptions = Prescription.with_patient_id(params[:term]).order(created_at: :desc).limit(10)
    render json: @outpatient_prescriptions.map{ |pre| { id: pre.id, order_type: pre.order_type.humanize, status: pre.status.humanize, professional: pre.professional_fullname,
    supply_count: pre.quantity_ord_supply_lots.count, created_at: pre.created_at.strftime("%d/%m/%Y") } }
  end

  def set_order_product
    @order_product = params[:order_product_id].present? ? OutpatientPrescriptionProduct.find(params[:order_product_id]) : OutpatientPrescriptionProduct.new
  end

  private

  # Set prescription and patient to prescription
  def set_patient_to_outpatient_prescription
    @outpatient_prescription = params[:outpatient_prescription].present? ? OutpatientPrescription.create(outpatient_prescription_params) : OutpatientPrescription.new
    @patient = Patient.find(params[:patient_id])
    @outpatient_prescription.patient_id =  @patient.id
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_outpatient_prescription
    @outpatient_prescription = OutpatientPrescription.find(params[:id])
  end

  def outpatient_prescription_params
    params.require(:outpatient_prescription).permit(
      :professional_id,
      :patient_id,
      :observation,        
      :date_prescribed,
      :expiry_date,
      outpatient_prescription_products_attributes: [
        :id, 
        :product_id, 
        :lot_stock_id,
        :request_quantity,
        :delivery_quantity,
        :observation,
        :_destroy,
        order_prod_lot_stocks_attributes: [
          :id,
          :quantity,
          :lot_stock_id,
          :_destroy
        ]
      ]
    )
  end

  def dispensing?
    return params[:commit] == "dispensing"
  end
end
