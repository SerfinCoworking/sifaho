class Prescriptions::InpatientMovementsController < ApplicationController
  before_action :set_inpatient_movement, only: [:show, :edit, :update, :destroy]

  # GET /inpatient_movements
  # GET /inpatient_movements.json
  def index
    @filterrific = initialize_filterrific(
      InpatientMovement.establishment(current_user.sector.establishment),
      params[:filterrific],
      select_options: {
        sorted_by: InpatientMovement.options_for_sorted_by
      },
      persistence_id: false,
    ) or return
    @inpatient_movements = @filterrific.find.paginate(page: params[:page], per_page: 15)
  end

  # GET /inpatient_movements/1
  # GET /inpatient_movements/1.json
  def show
  end

  # GET /inpatient_movements/new
  def new
    @inpatient_movement = InpatientMovement.new
    @inpatient_movement.movement_type_id = params[:movement_type_id] if params[:movement_type_id].present?
    @inpatient_movement.bed_id = params[:bed_id] if params[:bed_id].present?
    if @inpatient_movement.bed.present? && @inpatient_movement.bed.patient.present?
      @inpatient_movement.patient_id = @inpatient_movement.bed.patient.id
    end
    @patient = Patient.new
  end

  # GET /inpatient_movements/1/edit
  def edit
  end

  # POST /inpatient_movements
  # POST /inpatient_movements.json
  def create
    @inpatient_movement = InpatientMovement.new(inpatient_movement_params)
    @inpatient_movement.user = current_user
    authorize @inpatient_movement

    respond_to do |format|
      if @inpatient_movement.save
        format.html { redirect_to @inpatient_movement.bed, notice: 'El movimiento del paciente se ha creado correctamente.' }
        format.json { render :show, status: :created, location: @inpatient_movement }
      else
        @patient = @inpatient_movement.patient.present? ? @inpatient_movement.patient : Patient.new
        format.html { render :new }
        format.json { render json: @inpatient_movement.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /inpatient_movements/1
  # PATCH/PUT /inpatient_movements/1.json
  def update
    respond_to do |format|
      if @inpatient_movement.update(inpatient_movement_params)
        format.html { redirect_to @inpatient_movement, notice: 'El movimiento del paciente se ha modificado correctamente.' }
        format.json { render :show, status: :ok, location: @inpatient_movement }
      else
        format.html { render :edit }
        format.json { render json: @inpatient_movement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /inpatient_movements/1
  # DELETE /inpatient_movements/1.json
  def destroy
    @inpatient_movement.destroy
    respond_to do |format|
      format.html { redirect_to inpatient_movements_url, notice: 'El movimiento del paciente se ha eliminado correctamente.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_inpatient_movement
      @inpatient_movement = InpatientMovement.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def inpatient_movement_params
      params.require(:inpatient_movement).permit(:bed_id, :patient_id, :movement_type_id, :observations)
    end
end
