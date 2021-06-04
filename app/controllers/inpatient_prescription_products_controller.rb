class InpatientPrescriptionProductsController < ApplicationController
  before_action :set_inpatient_prescription_product, only: [:show, :edit, :update, :destroy]

  # GET /inpatient_prescription_products
  # GET /inpatient_prescription_products.json
  def index
    @inpatient_prescription_products = InpatientPrescriptionProduct.all
  end

  # GET /inpatient_prescription_products/1
  # GET /inpatient_prescription_products/1.json
  def show
  end

  # GET /inpatient_prescription_products/new
  def new
    @inpatient_prescription_product = InpatientPrescriptionProduct.new
  end

  # GET /inpatient_prescription_products/1/edit
  def edit
  end

  # POST /inpatient_prescription_products
  # POST /inpatient_prescription_products.json
  def create
    @inpatient_prescription_product = InpatientPrescriptionProduct.new(inpatient_prescription_product_ajax_params)
    @inpatient_prescription_product.inpatient_prescription_id = params[:inpatient_prescription_id]
    @inpatient_prescription_product.status = 'sin_proveer'

    respond_to do |format|
      if @inpatient_prescription_product.save!
        flash.now[:success] = "El producto #{@inpatient_prescription_product.product.name} se ha guardado correctamente."
        format.js
      else
        format.html { render :new }
        format.json { render json: @inpatient_prescription_product.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # PATCH/PUT /inpatient_prescription_products/1
  # PATCH/PUT /inpatient_prescription_products/1.json
  def update
    respond_to do |format|
      if @inpatient_prescription_product.update!(inpatient_prescription_product_ajax_params)
        flash.now[:success] = "El producto #{@inpatient_prescription_product.product.name} se ha guardado correctamente."
        format.js
      else
        format.html { render :edit }
        format.json { render json: @inpatient_prescription_product.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # DELETE /inpatient_prescription_products/1
  # DELETE /inpatient_prescription_products/1.json
  def destroy
    @inpatient_prescription_product.destroy
    respond_to do |format|
      flash.now[:success] = "El producto #{@inpatient_prescription_product.product.name} se ha eliminado correctamente."
      format.js
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_inpatient_prescription_product
    @inpatient_prescription_product = InpatientPrescriptionProduct.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def inpatient_prescription_product_params
    params.require(:inpatient_prescription_product).permit(
      :inpatient_prescription_id, :product_id, :dose_quantity, :interval, :status, :observation, :dispensed_by_id)
  end

  def inpatient_prescription_product_ajax_params
    params.require(:inpatient_prescription_product).permit(:parent_id, :product_id, :quantity, :dose_total, :observation)
  end
end