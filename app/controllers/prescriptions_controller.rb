class PrescriptionsController < ApplicationController
  before_action :set_prescription, only: [:show, :edit, :update, :destroy, :dispense, :delete, :return_status, 
    :return_cronic_confirm, :return_cronic_dispensation ]

  # GET /prescriptions
  # GET /prescriptions.json
  def index
    authorize Prescription
    @filterrific = initialize_filterrific(
      Prescription.with_establishment(current_user.establishment),
      params[:filterrific],
      select_options: {
        sorted_by: Prescription.options_for_sorted_by
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'created_at_desc'},
      available_filters: [
        :search_by_professional,
        :search_by_patient,
        :search_by_supply,
        :sorted_by,
        :with_order_type,
        :date_prescribed_since,
        :date_dispensed_since
      ],
    ) or return
    @prescriptions = @filterrific.find.page(params[:page]).per_page(15)
  end

  # GET /prescriptions/1
  # GET /prescriptions/1.json
  def show
    authorize @prescription
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /prescriptions/new
  def new
    authorize Prescription
    @prescription = Prescription.new
    @prescription.quantity_ord_supply_lots.build
  end


  # GET /prescriptions/new_cronic
  def new_cronic
    authorize Prescription
    @prescription = Prescription.new
    @prescription.quantity_ord_supply_lots.build
  end

  # GET /prescriptions/1/edit
  def edit
    authorize @prescription
  end

  # POST /prescriptions
  # POST /prescriptions.json
  def create
    @prescription = Prescription.new(prescription_params)
    authorize @prescription
    @prescription.created_by = current_user
    @prescription.provider_sector = current_user.sector
    @prescription.establishment = current_user.sector.establishment
    @prescription.remit_code = current_user.sector.name[0..3].upcase+'pres'+Prescription.with_deleted.maximum(:id).to_i.next.to_s

    respond_to do |format|
      if @prescription.save!
        # Si se entrega la prescripción
        begin
          if dispensing?
            if @prescription.ambulatoria?
              @prescription.dispense_by(current_user.id)
            elsif @prescription.cronica?
              @prescription.dispense_cronic_by(current_user)
            end
              @prescription.create_notification(current_user, "creó y dispensó")
              flash[:success] = "La prescripción "+@prescription.order_type+" de "+@prescription.patient.fullname+" se ha creado y dispensado correctamente."
          else
            @prescription.create_notification(current_user, "creó")
            flash[:success] = "La prescripción "+@prescription.order_type+" de "+@prescription.patient.fullname+" se ha creado correctamente." 
          end
        rescue ArgumentError => e
          flash[:alert] = e.message
        end
        format.html { redirect_to @prescription }
      else
        flash[:error] = "La prescripción no se ha podido crear."
        if prescription_params[:order_type] == 'ambulatoria'
          format.html { render :new }
        elsif prescription_params[:order_type] == 'cronica'
          format.html { render :new_cronic }
        end
      end
    end
  end

  # PATCH/PUT /prescriptions/1
  # PATCH/PUT /prescriptions/1.json
  def update
    authorize @prescription

    respond_to do |format|
      if @prescription.update_attributes(prescription_params)
        begin
          if dispensing?
            if @prescription.ambulatoria?
              @prescription.dispense_by(current_user)
            elsif @prescription.cronica?
              @prescription.dispense_cronic_by(current_user)
            end
            @prescription.create_notification(current_user, "auditó y dispensó")
            flash[:success] = "La prescripción "+@prescription.order_type+" de "+@prescription.professional.fullname+" se ha modificado y dispensado correctamente."
          else
            @prescription.create_notification(current_user, "auditó")
            flash[:success] = "La prescripción de "+@prescription.professional.fullname+" se ha modificado correctamente."
          end
        rescue ArgumentError => e
          flash[:notice] = e.message
          format.html { render :edit }
        else
          format.html { redirect_to @prescription }
        end
      else
        flash[:error] = "La prescripción de "+@prescription.professional.fullname+" no se ha podido modificar."
        format.html { render :edit }
      end
    end
  end

  # DELETE /prescriptions/1
  # DELETE /prescriptions/1.json
  def destroy
    authorize @prescription
    @professional_fullname = @prescription.professional.fullname
    @prescription.destroy
    respond_to do |format|
      flash.now[:success] = "La prescripción de "+@professional_fullname+" se ha eliminado correctamente."
      format.js
    end
  end

  # GET /prescriptions/1/dispense
  def dispense
    authorize @prescription
    respond_to do |format|
      begin
        @prescription.dispense_by(current_user.id)

      rescue ArgumentError => e
        flash.now[:error] = e.message
        format.js
      else
        if @prescription.save!
          flash.now[:success] = "La prescripción de "+@prescription.professional.fullname+" se ha dispensado correctamente."
          format.js
        else
          flash.now[:error] = "La prescripción no se ha podido dispensar."
          format.js
        end
      end
    end
  end

  def return_cronic_dispensation
    authorize @prescription
    respond_to do |format|
      begin
        @prescription.return_cronic_dispensation
        @prescription.create_notification(current_user, "retornó una dispensación")
      rescue ArgumentError => e
        flash[:alert] = e.message
      else
        flash[:notice] = 'Se ha retornado una dispensación de la prescripción crónica.'
      end
      format.html { redirect_to @prescription }
    end
  end

  def return_status
    authorize @prescription
    respond_to do |format|
      begin
        @prescription.return_status
      rescue ArgumentError => e
        flash[:alert] = e.message
      else
        flash[:notice] = 'La prescripción se ha retornado a '+@prescription.status+'.'
      end
      format.html { redirect_to @prescription }
    end
  end

  # GET /prescription/1/delete
  def delete
    authorize @prescription
    respond_to do |format|
      format.js
    end
  end

  def get_by_patient_id
    @prescriptions = Prescription.with_patient_id(params[:term]).order(created_at: :desc).limit(10)
    render json: @prescriptions.map{ |pre| { id: pre.id, order_type: pre.order_type.humanize, status: pre.status.humanize, professional: pre.professional_fullname, 
    supply_count: pre.quantity_ord_supply_lots.count, created_at: pre.created_at.strftime("%d/%m/%Y") } }
  end

  def generate_order_report(prescription)

    report = Thinreports::Report.new layout: File.join(Rails.root, 'app', 'reports', 'prescription', 'ambulatory.tlf')

    report.use_layout File.join(Rails.root, 'app', 'reports', 'prescription', 'ambulatory.tlf'), :default => true
    report.use_layout File.join(Rails.root, 'app', 'reports', 'prescription', 'ambulatory.tlf'), id: :other_page
    
    prescription.quantity_ord_supply_lots.joins(:supply).order("name").each do |qosl|
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

        report.list.on_page_footer_insert do |footer|
          footer.item(:total_supplies).value(external_order.quantity_ord_supply_lots.count)
          footer.item(:total_requested).value(external_order.quantity_ord_supply_lots.sum(&:requested_quantity))
          footer.item(:total_delivered).value(external_order.quantity_ord_supply_lots.sum(&:delivered_quantity))
          footer.item(:total_obs).value(external_order.quantity_ord_supply_lots.where.not(provider_observation: [nil, ""]).count())
        end
      end
      
      if report.page_count == 1
        report.page[:applicant_sector] = external_order.applicant_sector.name
        report.page[:applicant_establishment] = external_order.applicant_establishment.name
        report.page[:provider_sector] = external_order.provider_sector.name
        report.page[:provider_establishment] = external_order.provider_establishment.name
        report.page[:observations] = external_order.observation
      end
    end
    

    report.pages.each do |page|
      page[:title] = 'Reporte de '+external_order.order_type.humanize.underscore
      page[:remit_code] = external_order.remit_code
      page[:requested_date] = external_order.requested_date.strftime('%d/%m/%YY')
      page[:page_count] = report.page_count
      page[:sector] = current_user.sector_name
      page[:establishment] = current_user.establishment_name
    end

    report.generate
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_prescription
      @prescription = Prescription.find(params[:id])
    end

    def prescription_params
      params.require(:prescription).permit(
        :observation, :date_received, :professional_id, :patient_id, :prescription_status_id,
        :prescribed_date, :expiry_date, :remit_code, :times_dispensation, :order_type,
        quantity_ord_supply_lots_attributes: [
          :id, :supply_id, :daily_dose, :treatment_duration, :requested_quantity, :delivered_quantity,
          :sector_supply_lot_id, :provider_observation, :_destroy
        ]
      )
    end

    def dispensing?
      submit = params[:commit]
      return submit == "Dispensar"
    end
end
