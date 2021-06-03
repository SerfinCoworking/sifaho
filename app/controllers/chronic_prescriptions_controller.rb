class ChronicPrescriptionsController < ApplicationController
  before_action :set_chronic_prescription, except: [:index, :new, :create ]
  before_action :set_patient_to_chronic_prescription, only: [ :new, :create ]

  # GET /chronic_prescriptions
  # GET /chronic_prescriptions.json
  def index
    authorize ChronicPrescription
    @filterrific = initialize_filterrific(
      ChronicPrescription.with_establishment(current_user.establishment),
      params[:filterrific],
      select_options: {
        sorted_by: ChronicPrescription.options_for_sorted_by,
        for_statuses: ChronicPrescription.options_for_statuses
      },
      persistence_id: false
    ) or return
    @chronic_prescriptions = @filterrific.find.paginate(page: params[:page], per_page: 15)
  end

  # GET /chronic_prescriptions/1
  # GET /chronic_prescriptions/1.json
  def show
    authorize @chronic_prescription

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        send_data generate_order_report(@chronic_prescription),
        filename: 'Rec_amb_'+@chronic_prescription.patient_last_name+'.pdf',
        type: 'application/pdf',
        disposition: 'inline'
      end
    end
  end

  # GET /chronic_prescriptions/new
  def new
    authorize ChronicPrescription
    @chronic_prescription.original_chronic_prescription_products.build
  end

  # GET /chronic_prescriptions/1/edit
  def edit
    authorize @chronic_prescription
  end

  # POST /chronic_prescriptions
  # POST /chronic_prescriptions.json
  def create
    authorize @chronic_prescription
    @chronic_prescription.provider_sector = current_user.sector
    @chronic_prescription.establishment = current_user.sector.establishment
    @chronic_prescription.remit_code = "CR"+DateTime.now.to_s(:number)
    @chronic_prescription.status = 'pendiente'

    respond_to do |format|
      # Si se entrega la receta
      begin
        @chronic_prescription.save!
        message = "La receta crónica de "+@chronic_prescription.patient.fullname+" se ha creado correctamente."
        notification_type = "creó"
        
        @chronic_prescription.create_notification(current_user, notification_type)
        if dispensing?
          format.html { redirect_to new_chronic_prescription_chronic_dispensation_path(@chronic_prescription), notice: message }
        else
          format.html { redirect_to @chronic_prescription, notice: message }
        end
      rescue ArgumentError => e
        # si fallo la validacion de stock debemos modificar el estado a proveedor_auditoria
        flash[:error] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @chronic_prescription_products = @chronic_prescription.original_chronic_prescription_products.present? ? @chronic_prescription.original_chronic_prescription_products : @chronic_prescription.original_chronic_prescription_products.build
        @chronic_prescription.patient = Patient.find(params[:patient_id])
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /chronic_prescriptions/1
  # PATCH/PUT /chronic_prescriptions/1.json
  def update
    authorize @chronic_prescription

    respond_to do |format|
      begin
        @chronic_prescription.update!(chronic_prescription_params)

        message = "La receta crónica de "+@chronic_prescription.patient.fullname+" se ha auditado correctamente."
        notification_type = "auditó"

        @chronic_prescription.create_notification(current_user, notification_type)
        if dispensing?
          format.html { redirect_to new_chronic_prescription_chronic_dispensation_path(@chronic_prescription), notice: message }
        else
          format.html { redirect_to @chronic_prescription, notice: message }
        end
      rescue ArgumentError => e
        flash[:error] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @chronic_prescription_products = @chronic_prescription.original_chronic_prescription_products.present? ? @chronic_prescription.original_chronic_prescription_products : @chronic_prescription.original_chronic_prescription_products.build        
        format.html { render :edit }
      end
    end
  end

  # DELETE /chronic_prescriptions/1
  # DELETE /chronic_prescriptions/1.json
  def destroy
    authorize @chronic_prescription
    @professional_fullname = @chronic_prescription.professional.fullname
    @chronic_prescription.destroy
    respond_to do |format|
      flash.now[:success] = "La receta de "+@professional_fullname+" se ha eliminado correctamente."
      format.js
    end
  end

  def return_dispensation
    authorize @chronic_prescription
    respond_to do |format|
      begin
        @chronic_prescription.return_dispensation(current_user)
      rescue ArgumentError => e
        flash[:error] = e.message
      else
        flash[:notice] = 'La receta se ha retornado a '+@chronic_prescription.status+'.'
      end
      format.html { redirect_to @chronic_prescription }
    end
  end

  def finish
    authorize @chronic_prescription
    respond_to do |format|
      begin
        @chronic_prescription.finish_by(current_user)
        flash[:success] = 'La receta crónica se ha finalizado correctamente.'
      rescue ArgumentError => e
        flash[:error] = e.message
      end
      format.html { redirect_to @chronic_prescription }
    end
  end

  private
    # Set prescription and patient to prescription
    def set_patient_to_chronic_prescription
      @chronic_prescription = params[:chronic_prescription].present? ? ChronicPrescription.create(chronic_prescription_params) : ChronicPrescription.new
      @patient = Patient.find(params[:patient_id])
      @chronic_prescription.patient_id =  @patient.id
    end
    
    # Use callbacks to share common setup or constraints between actions.
    def set_chronic_prescription
      @chronic_prescription = ChronicPrescription.find(params[:id])
    end

    def chronic_prescription_params
      params.require(:chronic_prescription).permit(
        :professional_id,
        :diagnostic,        
        :date_prescribed,
        :expiry_date,
        original_chronic_prescription_products_attributes: [
          :id,
          :product_id, 
          :request_quantity,
          :total_request_quantity,
          :observation,
          :_destroy
        ]
      )
    end

    def dispensing?
      return params[:commit] == "dispensing"
    end
end
