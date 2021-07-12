class BedsController < ApplicationController
  before_action :set_bed, only: %i[show edit update destroy]
  before_action :assign_records, only: %i[index new create edit update]

  # GET /beds
  # GET /beds.json
  def index
    authorize Bed
    @filterrific = initialize_filterrific(
      Bed.establishment(current_user.sector.establishment),
      params[:filterrific],
      select_options: {
        with_status: Bed.options_for_status,
        sorted_by: Bed.options_for_sorted_by
      },
      persistence_id: false
    ) or return
    @beds = @filterrific.find.page(params[:page]).per_page(15)
  end

  # GET /beds/1
  # GET /beds/1.json
  def show
    authorize @bed
    return unless @bed.patient.present?

    @filterrific = initialize_filterrific(@bed.patient.inpatient_prescriptions, params[:filterrific], persistence_id: false)
    @inpatient_prescriptions = @filterrific.find
  end

  # GET /beds/new
  def new
    authorize Bed
    @bed = Bed.new
    @beds = Bed.joins(:bedroom).pluck(:id, :name, 'bedrooms.name')
  end

  # GET /beds/1/edit
  def edit
    authorize @bed
  end

  # POST /beds
  # POST /beds.json
  def create
    @bed = Bed.new(bed_params)
    authorize @bed

    respond_to do |format|
      if @bed.save
        format.html { redirect_to @bed, notice: 'La cama de internación se ha creado correctamente.' }
        format.json { render :show, status: :created, location: @bed }
      else
        format.html { render :new }
        format.json { render json: @bed.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /beds/1
  # PATCH/PUT /beds/1.json
  def update
    authorize @bed
    respond_to do |format|
      if @bed.update(bed_params)
        format.html { redirect_to @bed, notice: 'La cama de internación se ha modificado correctamente.' }
        format.json { render :show, status: :ok, location: @bed }
      else
        format.html { render :edit }
        format.json { render json: @bed.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /beds/1
  # DELETE /beds/1.json
  def destroy
    authorize @bed
    @bed.destroy
    respond_to do |format|
      format.html { redirect_to beds_url, notice: 'La cama de internación se ha enviado a la papelera correctamente.' }
      format.json { head :no_content }
    end
  end

  def new_bed
    authorize Bed
    @bed = Bed.new
  end

  def admit_patient
    authorize Bed
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_bed
    @bed = Bed.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def bed_params
    params.require(:bed).permit(:name, :bedroom_id, :service_id)
  end

  def assign_records
    @bedrooms = Bedroom.select(:id, :name)
                       .establishment(current_user.sector.establishment_id)
    @services = Sector.select(:id, :name)
                      .with_establishment_id(current_user.sector.establishment_id)
                      .provide_hospitalization
  end
end
