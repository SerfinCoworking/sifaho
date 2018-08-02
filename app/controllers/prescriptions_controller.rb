class PrescriptionsController < ApplicationController
  before_action :set_prescription, only: [:show, :edit, :update, :destroy, :dispense, :delete]

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
    @supplies = SupplyLot.all
    @prescription.quantity_supply_lots.build
    @filtered_lots = []
  end

  # GET /prescriptions/1/edit
  def edit
    @professionals = Professional.all
    @supplies = SupplyLot.all
    @patients = Patient.all
    @patient_types = PatientType.all
    @sectors = Sector.all
  end

  # POST /prescriptions
  # POST /prescriptions.json
  def create
    @prescription = Prescription.new(prescription_params)

    respond_to do |format|
      if @prescription.save!
        # Si se entrega la prescripción
        if dispensing?
          begin
            @prescription.dispense
            flash.now[:success] = "La prescripción de "+@prescription.professional.full_name+" se ha creado y entregado correctamente."
          rescue ArgumentError => e
            flash.now[:error] = "Se ha creado pero no se ha podido entregar: "+e.message
          end
        else
          flash.now[:success] = "La prescripción de "+@prescription.professional.full_name+" se ha creado correctamente."
        end
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
    respond_to do |format|
      if @prescription.update_attributes(prescription_params)
        if dispensing?
          begin
            @prescription.dispense
            flash.now[:success] = "La prescripción de "+@prescription.professional.full_name+" se ha modificado y entregado correctamente."
          rescue ArgumentError => e
            flash.now[:error] = "La prescripción se ha modificado pero no se entregó: "+e.message
          end
        else
          flash.now[:success] = "La prescripción de "+@prescription.professional.full_name+" se ha modificado correctamente."
        end
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
    respond_to do |format|
      begin
        @prescription.dispense

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

  # GET /prescription/1/delete
  def delete
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
                                             quantity_supply_lots_attributes: [:id, :supply_lot_id, :quantity, :_destroy],
                                             patient_attributes: [:id, :first_name, :last_name, :dni, :patient_type_id]
                                          )
    end

    def dispensing?
      submit = params[:commit]
      return submit == "Cargar y dispensar" || submit == "Guardar y dispensar"
    end
end
