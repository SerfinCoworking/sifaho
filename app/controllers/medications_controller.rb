class MedicationsController < ApplicationController
  before_action :set_medication, only: [:show, :edit, :update, :destroy, :delete]

  # GET /medications
  # GET /medications.json
  def index
    @filterrific = initialize_filterrific(
      Medication,
      params[:filterrific],
      select_options: {
        sorted_by: Medication.options_for_sorted_by
      },
      persistence_id: false,
      default_filter_params: {sorted_by: 'created_at_desc'},
      available_filters: [
        :sorted_by,
        :search_query,
        :date_received_at,
        :status,
      ],
    ) or return
    @medications = @filterrific.find.page(params[:page]).per_page(8)


    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /medications/1
  # GET /medications/1.json
  def show
    _percent = @medication.quantity.to_f / @medication.initial_quantity  * 100 unless @medication.initial_quantity == 0
    @percent_quantity_medication = _percent
    respond_to do |format|
      format.js
    end
  end

  # GET /medications/new
  def new
    @medication = Medication.new
    @medication.build_medication_brand
    @medication.medication_brand.build_laboratory
    @vademecums = Vademecum.all
    @medication_brands = MedicationBrand.all
    @laboratories = Laboratory.all
  end

  # GET /medications/1/edit
  def edit
    @vademecums = Vademecum.all
    @medication_brands = MedicationBrand.all
    @laboratories = Laboratory.all
  end

  # POST /medications
  # POST /medications.json
  def create
    @medication = Medication.new(medication_params)
    if medication_params[:medication_brand_id].present?
      @medication.update_attribute(:medication_brand_id, medication_params[:medication_brand_id])
    end

    respond_to do |format|
      if @medication.save
        flash.now[:success] = "El lote de "+@medication.full_info+" se ha cargado correctamente."
        format.js
      else
        flash.now[:error] = "El lote de medicamentos no se ha podido cargar."
        format.js
      end
    end
  end

  # PATCH/PUT /medications/1
  # PATCH/PUT /medications/1.json
  def update
    respond_to do |format|
      if @medication.update(medication_params)
        flash.now[:success] = "El lote de "+@medication.full_info+" se ha modificado correctamente."
        format.js
      else
        flash.now[:error] = "El lote de "+@medication.full_info+" no se ha podido modificar."
        format.js
      end
    end
  end

  # DELETE /medications/1
  # DELETE /medications/1.json
  def destroy
    @medication_info = @medication.full_info
    @medication.destroy
    respond_to do |format|
      flash.now[:success] = "El lote de "+@medication_info+" se ha eliminado correctamente."
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_medication
      @medication = Medication.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def medication_params
      params.require(:medication).permit(:vademecum_id, :quantity, :date_received,
                                         :expiry_date, :medication_brand_id,
                                         medication_brand_attributes: [:id, :name, :description, :laboratory_id,
                                         laboratory_attributes: [:id, :name, :address]])
    end
end
