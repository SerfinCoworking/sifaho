class OutpatientPrescriptionsController < ApplicationController
  before_action :set_outpatient_prescription, only: [:show, :edit, :update, :destroy, :dispense, :delete,
    :return_cronic_dispensation, :confirm_return_cronic, :return_ambulatory_dispensation, :confirm_return_ambulatory ]

  # GET /outpatient_prescriptions
  # GET /outpatient_prescriptions.json
  def index
    authorize OutpatientPrescription
    @filterrific = initialize_filterrific(
      OutpatientPrescription.with_establishment(current_user.establishment),
      params[:filterrific],
      persistence_id: false
    ) or return
    @outpatient_prescriptions = @filterrific.find.page(params[:page]).per_page(15)
  end

  # GET /outpatient_prescriptions/1
  # GET /outpatient_prescriptions/1.json
  def show
    authorize @outpatient_prescription

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        send_data generate_order_report(@outpatient_prescription),
        filename: 'Rec_amb_'+@outpatient_prescription.patient_last_name+'.pdf',
        type: 'application/pdf',
        disposition: 'inline'
      end
    end
  end

  # GET /outpatient_prescriptions/new
  def new
    authorize OutpatientPrescription
    @outpatient_prescription = OutpatientPrescription.new
    @outpatient_prescription.outpatient_prescription_products.build
  end

  # GET /outpatient_prescriptions/1/edit
  def edit
    authorize @outpatient_prescription
  end

  # POST /outpatient_prescriptions
  # POST /outpatient_prescriptions.json
  def create
    @outpatient_prescription = OutpatientPrescription.new(outpatient_prescription_params)
    authorize @outpatient_prescription
    @outpatient_prescription.provider_sector = current_user.sector
    @outpatient_prescription.establishment = current_user.sector.establishment
    @outpatient_prescription.remit_code = current_user.sector.name[0..3].upcase+'pres'+OutpatientPrescription.maximum(:id).to_i.next.to_s
    
    @outpatient_prescription.expiry_date = DateTime.strptime(outpatient_prescription_params[:date_prescribed], "%d/%m/%Y") + 3.month
    @outpatient_prescription.status= dispensing? ? 'dispensada' : 'pendiente'

    respond_to do |format|
        # Si se entrega la receta
      begin
        @outpatient_prescription.save

        if(dispensing?); @outpatient_prescription.dispense_by(current_user.id); end

        message = dispensing? ? "La receta ambulatoria de "+@outpatient_prescription.patient.fullname+" se ha creado y dispensado correctamente." : "La receta ambulatoria de "+@outpatient_prescription.patient.fullname+" se ha creado correctamente."
        notification_type = dispensing? ? "creó y dispensó" : "creó"
        
        @outpatient_prescription.create_notification(current_user, notification_type)
        format.html { redirect_to @outpatient_prescription, notice: message }
      rescue ArgumentError => e
        # si fallo la validacion de stock debemos modificar el estado a proveedor_auditoria
        flash[:alert] = e.message
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
    @outpatient_prescription.expiry_date = DateTime.strptime(outpatient_prescription_params[:date_prescribed], "%d/%m/%Y") + 3.month

    respond_to do |format|
      begin

        @outpatient_prescription.update(outpatient_prescription_params)
        @outpatient_prescription.save!

        if(dispensing?); @outpatient_prescription.dispense_by(current_user); end

        message = dispensing? ? "La receta ambulatoria de "+@outpatient_prescription.patient.fullname+" se ha creado y dispensado correctamente." : "La receta ambulatoria de "+@outpatient_prescription.patient.fullname+" se ha creado correctamente."
        notification_type = dispensing? ? "auditó y dispensó" : "auditó"

        @outpatient_prescription.create_notification(current_user, notification_type)
        format.html { redirect_to @outpatient_prescription, notice: message }
      rescue ArgumentError => e
        flash[:alert] = e.message
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

  # GET /prescriptions/1/dispense
  # def dispense
  #   authorize @outpatient_prescription
  #   respond_to do |format|
  #     begin
  #       @outpatient_prescription.dispense_by(current_user.id)

  #     rescue ArgumentError => e
  #       flash.now[:error] = e.message
  #       format.js
  #     else
  #       if @outpatient_prescription.save!
  #         flash.now[:success] = "La receta de "+@outpatient_prescription.professional.fullname+" se ha dispensado correctamente."
  #         format.js
  #       else
  #         flash.now[:error] = "La receta no se ha podido dispensar."
  #         format.js
  #       end
  #     end
  #   end
  # end


  # def return_ambulatory_dispensation
  #   authorize @outpatient_prescription
  #   respond_to do |format|
  #     begin
  #       @outpatient_prescription.return_ambulatory_dispensation
  #     rescue ArgumentError => e
  #       flash[:alert] = e.message
  #     else
  #       flash[:notice] = 'La receta se ha retornado a '+@outpatient_prescription.status+'.'
  #     end
  #     format.html { redirect_to @outpatient_prescription }
  #   end
  # end

  def get_by_patient_id
    @outpatient_prescriptions = Prescription.with_patient_id(params[:term]).order(created_at: :desc).limit(10)
    render json: @outpatient_prescriptions.map{ |pre| { id: pre.id, order_type: pre.order_type.humanize, status: pre.status.humanize, professional: pre.professional_fullname,
    supply_count: pre.quantity_ord_supply_lots.count, created_at: pre.created_at.strftime("%d/%m/%Y") } }
  end

  def generate_order_report(prescription)
    report = Thinreports::Report.new layout: File.join(Rails.root, 'app', 'reports', 'prescription', 'first_page.tlf')

    report.use_layout File.join(Rails.root, 'app', 'reports', 'prescription', 'first_page.tlf'), :default => true
    
    if prescription.cronica?
      supply_relations = prescription.quantity_ord_supply_lots.sin_entregar.joins(:supply).order("name")
    else
      supply_relations = prescription.quantity_ord_supply_lots.joins(:supply).order("name")
    end
  
    supply_relations.each do |qosl|
      if report.page_count == 1 && report.list.overflow?
        report.start_new_page layout: :other_page do |page|
        end
      end
      
      report.list do |list|
        list.add_row do |row|
          row.values  supply_code: qosl.supply_id,
                      supply_name: qosl.supply.name,
                      requested_quantity: qosl.requested_quantity.to_s+" "+qosl.unity.pluralize(qosl.requested_quantity),
                      delivered_quantity: qosl.delivered_quantity.to_s+" "+qosl.unity.pluralize(qosl.delivered_quantity),
                      lot: qosl.sector_supply_lot_lot_code,
                      laboratory: qosl.sector_supply_lot_laboratory_name,
                      expiry_date: qosl.sector_supply_lot_expiry_date, 
                      applicant_obs: qosl.provider_observation
        end
      end
      
      if report.page_count == 1

        report.page[:order_type] = prescription.order_type
        report.page[:prescribed_date] = prescription.prescribed_date.strftime("%d/%m/%Y")
        report.page[:expiry_date] = prescription.expiry_date.present? ? prescription.expiry_date.strftime("%d/%m/%Y") : "---"
         
        report.page[:professional_name] = prescription.professional.fullname
        report.page[:professional_dni] = prescription.professional.dni
        report.page[:professional_enrollment] = prescription.professional.enrollment
        report.page[:professional_phone] = prescription.professional.phone

        report.page[:patien_name] = "#{prescription.patient.first_name} #{prescription.patient.last_name}"
        report.page[:patien_dni] = prescription.patient.dni

      end
    end
    

    report.pages.each do |page|
      page[:title] = 'Receta Digital'
      page[:remit_code] = prescription.remit_code
      page[:date_now] = DateTime.now.strftime("%d/%m/%YY")
      page[:page_count] = report.page_count
      page[:sector] = current_user.sector_name
      page[:establishment] = current_user.establishment_name
    end

    report.generate
  end
  
  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_outpatient_prescription
      @outpatient_prescription = OutpatientPrescription.find(params[:id])
    end

    def outpatient_prescription_params
      params.require(:outpatient_prescription).permit(
        :professional_id,
        :patient_id,
        :observation,

        # :date_received,

        :status,
        
        :date_prescribed,
        :expiry_date,
        # :remit_code,
        # :times_dispensation,
        # :order_type,
        outpatient_prescription_products_attributes: [
          :id, 
          :product_id, 
          :lot_stock_id,
          :request_quantity,
          :delivery_quantity,
          :applicant_observation,
          :provider_observation, 
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
