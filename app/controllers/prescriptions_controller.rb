class PrescriptionsController < ApplicationController
  before_action :set_prescription, only: [:show, :edit, :update, :destroy, :dispense, :delete, :return_status ]

  # GET /prescriptions
  # GET /prescriptions.json
  def index
    authorize Prescription
    @filterrific = initialize_filterrific(
      Prescription,
      params[:filterrific],
      select_options: {
        sorted_by: Prescription.options_for_sorted_by
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'created_at_desc'},
      available_filters: [
        :search_professional_and_patient,
        :search_supply_code,
        :search_supply_name,
        :sorted_by,
        :date_prescribed_since,
        :date_dispensed_since
      ],
    ) or return
    @prescriptions = @filterrific.find.page(params[:page]).per_page(8)
  end

  # GET /prescriptions/1
  # GET /prescriptions/1.json
  def show
    authorize @prescription
  end

  # GET /prescriptions/new
  def new
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

    respond_to do |format|
      if @prescription.save
        # Si se entrega la prescripción
        if dispensing?
          begin
            @prescription.dispense_by_user_id(current_user.id)
            flash[:success] = "La prescripción de "+@prescription.professional.full_name+" se ha creado y dispensado correctamente."
          rescue ArgumentError => e
            flash[:notice] = e.message
          end
        else
          flash[:success] = "La prescripción de "+@prescription.professional.full_name+" se ha creado correctamente."
        end
        format.html { redirect_to @prescription }
      else
        flash[:error] = "La prescripción no se ha podido crear."
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /prescriptions/1
  # PATCH/PUT /prescriptions/1.json
  def update
    authorize @prescription

    respond_to do |format|
      if @prescription.update_attributes(prescription_params)
        if dispensing?
          begin
            @prescription.dispense_by_user_id(current_user.id)
            flash[:success] = "La prescripción de "+@prescription.professional.full_name+" se ha modificado y dispensado correctamente."
          rescue ArgumentError => e
            flash[:notice] = e.message
          end
        else
          flash[:success] = "La prescripción de "+@prescription.professional.full_name+" se ha modificado correctamente."
        end
        format.html { redirect_to @prescription }
      else
        flash[:error] = "La prescripción de "+@prescription.professional.full_name+" no se ha podido modificar."
        format.html { render :edit }
      end
    end
  end

  # DELETE /prescriptions/1
  # DELETE /prescriptions/1.json
  def destroy
    authorize @prescription
    @professional_full_name = @prescription.professional.full_name
    @prescription.destroy
    respond_to do |format|
      flash.now[:success] = "La prescripción de "+@professional_full_name+" se ha eliminado correctamente."
      format.js
    end
  end

  # GET /prescriptions/1/dispense
  def dispense
    authorize @prescription
    respond_to do |format|
      begin
        @prescription.dispense_by_user_id(current_user.id)

      rescue ArgumentError => e
        flash.now[:error] = e.message
        format.js
      else
        if @prescription.save!
          flash.now[:success] = "La prescripción de "+@prescription.professional.full_name+" se ha dispensado correctamente."
          format.js
        else
          flash.now[:error] = "La prescripción no se ha podido dispensar."
          format.js
        end
      end
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_prescription
      @prescription = Prescription.find(params[:id])
    end

    def prescription_params
      params.require(:prescription).permit(
        :observation, :date_received, :professional_id, :patient_id, :prescription_status_id,
        :prescribed_date, :expiry_date, :remit_code,
        quantity_ord_supply_lots_attributes: [
          :id, :supply_id, :daily_dose, :treatment_duration, :requested_quantity, :delivered_quantity,
          :sector_supply_lot_id, :provider_observation, :_destroy
        ]
      )
    end

    def dispensing?
      submit = params[:commit]
      return submit == "Cargar y dispensar" || submit == "Guardar y dispensar"
    end
end
