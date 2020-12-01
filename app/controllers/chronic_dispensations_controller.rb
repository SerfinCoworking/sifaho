class ChronicDispensationsController < ApplicationController
  before_action :set_chronic_prescription, only: [:new, :create ]

  

  # GET /chronic_dispensations/new
  def new
    @chronic_dispensation = ChronicDispensation.new
    @chronic_dispensation.chronic_prescription = @chronic_prescription
    authorize @chronic_dispensation
  end

  # GET /chronic_prescriptions/1/edit
  # def edit
  #   authorize @chronic_prescription
  # end

  # POST /chronic_dispensations
  # POST /chronic_dispensations.json
  def create
    @chronic_dispensation = ChronicDispensation.new(chronic_prescription_dispensation_params)
    authorize @chronic_dispensation
    
    respond_to do |format|
      begin
        @chronic_dispensation.save!
        @chronic_dispensation.chronic_prescription.create_notification(current_user, "dispensó")
        flash.now[:success] = "La receta de "+@chronic_dispensation.chronic_prescription.professional.fullname+" se ha dispensado correctamente."
        format.html { redirect_to @chronic_prescription }
      rescue ArgumentError => e
        flash[:error] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        format.html { render :new }
      end
    end

  end

  # PATCH/PUT /chronic_prescriptions/1
  # PATCH/PUT /chronic_prescriptions/1.json
  # def update
  #   authorize @chronic_prescription

  #   respond_to do |format|
  #     begin
  #       @chronic_prescription.update!(chronic_prescription_params)

  #       message = "La receta crónica de "+@chronic_prescription.patient.fullname+" se ha auditado correctamente."
  #       notification_type = "auditó"

  #       @chronic_prescription.create_notification(current_user, notification_type)
  #       format.html { redirect_to @chronic_prescription, notice: message }
  #     rescue ArgumentError => e
  #       flash[:error] = e.message
  #     rescue ActiveRecord::RecordInvalid
  #     ensure
  #       @chronic_prescription_products = @chronic_prescription.original_chronic_prescription_products.present? ? @chronic_prescription.original_chronic_prescription_products : @chronic_prescription.original_chronic_prescription_products.build        
  #       format.html { redirect_to edit_chronic_prescription_path(@chronic_prescription) }
  #     end
  #   end
  # end

 

  def return_dispensation
    authorize @chronic_prescription
    respond_to do |format|
      begin
        @chronic_prescription.return_dispensation(current_user)
      rescue ArgumentError => e
        flash[:error] = e.message
      else
        flash[:notice] = 'La receta se ha retornado a '+@chronic_prescription.status+'.'
      end
      format.html { redirect_to @chronic_prescription }
    end
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
      )
    end

end
