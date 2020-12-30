class PurchasesController < ApplicationController
  before_action :set_purchase, only: [:show, :edit, :update, :destroy, :delete]

  # GET /purchases
  # GET /purchases.json
  def index
    @filterrific = initialize_filterrific(
      Purchase,
      params[:filterrific],
      persistence_id: false,
      available_filters: [
        :sorted_by,
        :search_name,
      ],
    ) or return
    @purchases = @filterrific.find.page(params[:page]).per_page(15)
  end

  # GET /purchases/1
  # GET /purchases/1.json
  def show
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /purchases/new
  def new
    @purchase = Purchase.new
    @purchase.purchase_products.build
    @purchase.purchase_products.first.line = "1" # debemos inicializar el primer renglon
    @sectors = []
  end

  # GET /purchases/1/edit
  def edit
  end

  # POST /purchases
  # POST /purchases.json
  def create
    @purchase = Purchase.new(purchase_params)
    @purchase.remit_code = 
    respond_to do |format|
      begin
        puts "==================PURCHASE"
        puts @purchase
        @purchase.save!
        message = "El abastecimiento se ha creado correctamente."
        format.html { redirect_to @purchase, notice: message }

        # @external_order.save!
        # message = sending? ? "La solicitud de abastecimiento se ha creado y enviado correctamente." : "La solicitud de abastecimiento se ha creado y se encuentra en auditoría."
        # notification_type = sending? ? "creó y envió" : "creó y auditó"

        # @external_order.create_notification(current_user, notification_type)        
      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @purchase.purchase_products.present? ? @purchase.purchase_products : @purchase.purchase_products.build
        @sectors = @purchase.provider_sector.present? ? @purchase.provider_establishment.sectors : [] 
          # flash[:error] = "El abastecimiento no se ha podido crear."
        format.html { render :new }
        # format.js { render layout: false, content_type: 'text/javascript' }
      end
    end

  end

  # PATCH/PUT /purchases/1
  # PATCH/PUT /purchases/1.json
  def update
    respond_to do |format|
      if @purchase.update(purchase_params)
        flash.now[:success] = @purchase.name + " se ha modificado correctamente."
        format.html { redirect_to @purchase }
        format.js
      else
        flash.now[:error] = @purchase.name + " no se ha podido modificar."
        format.html { render :edit }
        format.js
      end
    end
  end

  # DELETE /purchases/1
  # DELETE /purchases/1.json
  def destroy
    purchase_name = @purchase.name
    @purchase.destroy
    respond_to do |format|
      flash.now[:success] = "El abastecimiento "+purchase_name+" se ha eliminado correctamente."
      format.js
    end
  end

  # GET /purchase/1/delete
  def delete
    respond_to do |format|
      format.js
    end
  end
  
  def search_by_name
    @purchases = Purchase.order(:name).search_name(params[:term]).limit(10).where_not_id(current_user.sector.purchase_id)
    render json: @purchases.map{ |est| { label: est.name, id: est.id } }
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_purchase
    @purchase = Purchase.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def purchase_params
    params.require(:purchase).permit(
      :applicant_sector_id,
      :provider_sector_id,
      :area_id,
      :code_number,
      :observation,
      purchase_products_attributes: [
        :id,
        :product_id,
        :request_quantity,
        :line,
        :observation,
        :_destroy,
        order_prod_lot_stocks_attributes: [
          :id,
          :purchase_product_id,
          :lot_stock_id,
          :laboratory_id,
          :lot_code,
          :expiry_date,
          :quantity,
          :presentation,
          :_destroy
        ]
      ]
    )
  end

end
