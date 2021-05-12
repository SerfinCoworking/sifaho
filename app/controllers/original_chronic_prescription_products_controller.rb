class OriginalChronicPrescriptionProductsController < ApplicationController
  before_action :set_original_chronic_prescription_product, only: [:finish_treatment, :update_treatment]

  # GET /chronic_prescriptions
  # GET /chronic_prescriptions.json
  def finish_treatment
    authorize @original_product
    respond_to do |format|
      format.js
    end
  end

  def update_treatment
    authorize @original_product
    @original_product.treatment_status = 'terminado_manual'
    respond_to do |format|
      if @original_product.update(finish_treatment_params)
        flash.now[:success] = "Se ha terminado el tratamiento de #{@original_product.product_name} correctamente."
        format.js
      else
        flash.now[:error] = "No se ha podido terminar el tratamiento de #{@original_product.product_name}."
        format.js { render :finish_treatment }
      end
    end
  end

  private
    def set_original_chronic_prescription_product
      @original_product = OriginalChronicPrescriptionProduct.find(params[:original_product_id])
    end

    def finish_treatment_params
      params.require(:original_chronic_prescription_product).permit(
        :finished_by_professional_id,
        :finished_observation,
      )
    end
end
