class Prescriptions::ChronicDispensationsController < ApplicationController
  include FindLots

  before_action :set_chronic_prescription, only: %i[new create return_dispensation]

  # GET /chronic_dispensations/new
  def new
    @chronic_dispensation = ChronicDispensation.new
    @chronic_dispensation.chronic_prescription = @chronic_prescription
    @chronic_prescription.original_chronic_prescription_products.each do |ocpp|
      @chronic_dispensation.dispensation_types.build(original_chronic_prescription_product_id: ocpp.id)
    end
    authorize @chronic_dispensation
  end

  def create
    @chronic_dispensation = ChronicDispensation.new(chronic_prescription_dispensation_params)
    @chronic_dispensation.provider_sector = current_user.sector
    authorize @chronic_dispensation

    respond_to do |format|
      begin
        @chronic_dispensation.save!
        @chronic_dispensation.chronic_prescription.create_notification(current_user, 'dispensó')
        flash.now[:success] = "La receta de #{@chronic_dispensation.chronic_prescription.professional.fullname} se ha
                               dispensado correctamente."
        format.html { redirect_to @chronic_prescription }
      rescue ArgumentError => e
        flash[:error] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @chronic_prescription.original_chronic_prescription_products.excluding_ids(@chronic_dispensation.dispensation_types.map(&:original_chronic_prescription_product_id)).each do |ocpp|
          @chronic_dispensation.dispensation_types.build(original_chronic_prescription_product_id: ocpp.id)
        end
        format.html { render :new }
      end
    end
  end

  def return_dispensation_modal
    @chronic_dispensation = ChronicDispensation.find(params[:chronic_dispensation_id])
    authorize @chronic_dispensation
  end

  def return_dispensation
    @chronic_dispensation = ChronicDispensation.find(params[:chronic_dispensation_id])
    authorize @chronic_dispensation
    respond_to do |format|
      begin
        @chronic_dispensation.return_dispensation
        @chronic_dispensation.destroy
        @chronic_prescription.return_dispense_by(current_user)
        flash[:success] = "La receta de #{@chronic_dispensation.chronic_prescription.professional.fullname} se ha
                           retornado una dispensa correctamente."
      rescue ArgumentError => e
        flash[:error] = e.message
      end
      format.html { redirect_to chronic_prescription_path(@chronic_prescription) }
    end
  end

  def set_order_product
    @order_product = params[:order_product_id].present? ? OutpatientPrescriptionProduct.find(params[:order_product_id]) : OutpatientPrescriptionProduct.new
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_chronic_prescription
    @chronic_prescription = ChronicPrescription.find(params[:chronic_prescription_id])
  end

  def chronic_prescription_dispensation_params
    params.require(:chronic_dispensation).permit(
      :chronic_prescription_id,
      :observation,
      :status,
      :_destroy,
      dispensation_types_attributes: [
        :quantity,
        :quantity_type,
        :original_chronic_prescription_product_id,
        chronic_prescription_products_attributes: [
          :id, 
          :original_chronic_prescription_product_id,
          :product_id, 
          :lot_stock_id,
          :request_quantity,
          :delivery_quantity,
          :observation,
          :_destroy,
          order_prod_lot_stocks_attributes: [
            :id,
            :quantity,
            :lot_stock_id,
            :_destroy
          ]
        ]
      ]
    )
  end
end
