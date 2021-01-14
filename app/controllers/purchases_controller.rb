class PurchasesController < ApplicationController
  before_action :set_purchase, only: [:show, :edit, :update, :destroy, :delete, :set_products, :save_products, :save_and_receive_purchase]

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
    @sectors = []
  end

  # GET /purchases/1/edit
  def edit
    @sectors = @purchase.provider_sector.present? ? @purchase.provider_establishment.sectors : [] 
  end


  # POST /purchases
  # Guardamos los datos principales de la compra
  # sin validar los productos asociados
  # POST /purchases.json
  def create
    @purchase = Purchase.new(purchase_params)
    @purchase.applicant_sector_id = current_user.sector.id
    @purchase.status = 'inicial'
    respond_to do |format|
      begin
        @purchase.save!
        @purchase.create_notification(current_user, "creó")        
        format.html { redirect_to set_products_purchase_path(@purchase), notice: "El remito se ha creado correctamente." }

      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @sectors = @purchase.provider_sector.present? ? @purchase.provider_establishment.sectors : [] 
        flash[:error] = "El remito no se ha podido crear."
        format.html { render :new }
      end
    end

  end

  # PATCH/PUT /purchases/1
  # PATCH/PUT /purchases/1.json
  def update
    respond_to do |format|
      begin
        @purchase.update!(purchase_params)
        @purchase.create_notification(current_user, "auditó")        
        format.html { redirect_to set_products_purchase_path(@purchase), notice: "El remito se ha modificado correctamente." }
      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @sectors = @purchase.provider_sector.present? ? @purchase.provider_establishment.sectors : [] 
        flash[:error] = "El remito no se ha podido modificar."
        format.html { render :edit }
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

  def set_products
    # este metodo se utiliza para guardar el listado de productos asignados a la compra
    # debe validar los atributos de cada producto y lote asociado
    # Si no tiene productos asociados debes hacer un build y setear el renglon
    if @purchase.purchase_products.count == 0
      @purchase.purchase_products.build
      @purchase.purchase_products.first.line = "1" # debemos inicializar el primer renglon
    end
  end
  
  def save_products
    
    @purchase.status = 'auditoria'
    respond_to do |format|
      begin
        @purchase.update!(purchase_products_params)
        @purchase.save!
        @purchase.create_notification(current_user, 'auditó')        
        format.html { redirect_to @purchase, notice: "Los productos se han cargado correctamente." }

      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @purchase.purchase_products.present? ? @purchase.purchase_products : @purchase.purchase_products.build
        message = "No se han podido cargar productos en el remito."
        format.html { render :set_products, notice: message }
      end
    end
  end
  
  def save_and_receive_purchase    
    respond_to do |format|
      begin
        @purchase.receive_remit_by(current_user)
        message = "El remito se ha recibido correctamente."
        format.html { redirect_to @purchase, notice: message }
      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @purchase.purchase_products.present? ? @purchase.purchase_products : @purchase.purchase_products.build
        message = "No se ha podido recibir el remito."
        format.html { redirect_to save_products_purchase_path(@purchase), notice: message }
      end
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
      :observation
    )
  end
  
  def purchase_products_params
    params.require(:purchase).permit(
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
          :position,
          :_destroy
        ]
      ]
    )
  end

  def receive?
    return params[:commit] == "receive"
  end

end
