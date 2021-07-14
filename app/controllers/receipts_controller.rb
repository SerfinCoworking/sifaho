class ReceiptsController < ApplicationController
  before_action :set_receipt, only: [:show, :new, :edit, :update, :delete, :destroy]

  # GET /receipts
  # GET /receipts.json
  def index
    authorize Receipt
    @filterrific = initialize_filterrific(
      Receipt.applicant(current_user.sector).order(created_at: :desc),
      params[:filterrific],
      select_options: { },
      persistence_id: false
    ) or return
    @receipts = @filterrific.find.page(params[:page]).per_page(15)
  end

  # GET /receipts/1
  # GET /receipts/1.json
  def show
    respond_to do |format|
      format.pdf do
        send_data generate_order_report(@receipt), filename: "recibo_#{@receipt.remit_code}.pdf", type: 'application/pdf',
                                                   disposition: 'inline'
      end
    end
  end

  # GET /receipts/new
  def new
    authorize Receipt
    @provenances = LotProvenance.all
  end

  # GET /receipts/1/edit
  def edit
    authorize @receipt
    @provenances = LotProvenance.all
  end

  # POST /receipts
  # POST /receipts.json
  def create
    @receipt = Receipt.new(receipt_params)
    authorize @receipt
    respond_to do |format|
      @receipt.applicant_sector = current_user.sector
      @receipt.created_by = current_user
      @receipt.code = "RE"+DateTime.now.to_s(:number)
      
      begin
        @receipt.auditoria! #default status
      
        if receiving?
          @receipt.receive_remit(current_user)
          @receipt.create_notification(current_user, "creó y realizó")
          message = 'El recibo se ha creado y realizado correctamente'
        else
          @receipt.create_notification(current_user, "creó")
          message = 'El recibo se ha creado y se encuentra en auditoría.'
        end

        format.html { redirect_to @receipt, notice: message }
        format.json { render :show, status: :created, location: @receipt }
      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @sectors = @receipt.provider_sector.present? ? @receipt.provider_sector.establishment.sectors : []
        @receipt_products = @receipt.receipt_products.present? ? @receipt.receipt_products : @receipt.receipt_products.build
        @provenances = LotProvenance.all
        
        format.html { render :new }
        format.json { render json: @receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /receipts/1
  # PATCH/PUT /receipts/1.json
  def update
    authorize @receipt
    respond_to do |format|

      @receipt.update(receipt_params)
      begin
        @receipt.save!
        if receiving?
          @receipt.receive_remit(current_user)
          @receipt.create_notification(current_user, "auditó y realizó")
          message = 'El recibo se ha auditado y realizado correctamente'
        else
          @receipt.create_notification(current_user, "auditó")
          message = 'El recibo se ha auditado correctamente'
        end
        format.html { redirect_to @receipt, notice: message }
        format.json { render :show, status: :ok, location: @receipt }
      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @sectors = @receipt.provider_sector.present? ? @receipt.provider_sector.establishment.sectors : []
        @receipt_products = @receipt.receipt_products.present? ? @receipt.receipt_products : @receipt.receipt_products.build

        format.html { render :edit }
        format.json { render json: @receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /receipts/1
  # DELETE /receipts/1.json
  def destroy
    authorize @receipt
    @sector_name = @receipt.applicant_sector.name
    @receipt.destroy
    respond_to do |format|
      flash.now[:success] = "Recibo de "+@sector_name+" se ha eliminado."
      format.js
    end
  end

  # GET /external_order/1/delete
  def delete
    authorize @receipt
    respond_to do |format|
      format.js
    end
  end

  def generate_order_report(stock)
    report = Thinreports::Report.new

    report.use_layout File.join(Rails.root, 'app', 'reports', 'stock', 'one_stock_report.tlf'), default: true

    # Comenzamos con la pagina principal
    report.start_new_page

    # Agregamos el encabezado
    report.page[:title] = 'Reporte de stock de un producto'
    report.page[:requested_date] = DateTime.now.strftime('%d/%m/%YY')
    report.page[:efector] = current_user.sector_name+" "+current_user.establishment_name
    report.page[:product_code].value(@stock.product_code)
    report.page[:product_name].value(@stock.product_name)
    report.page[:product_area].value(@stock.product_area_name)
    report.page[:stock_quantity].value(@stock.total_quantity)
    report.page[:username].value("DNI: "+current_user.dni.to_s+", "+current_user.full_name)

    @movements = @stock.movements.sort_by{|e| e[:created_at]}.last(10).reverse
    @lot_stocks = @stock.lot_stocks.greater_than_zero

    report.page[:movements_title].value("Últimos "+@movements.count.to_s+" movimientos")
    # Se van agregando los productos
    @movements.each_with_index do |movement, index|
      # Luego de que la primer pagina ya halla sido rellenada, agregamos la pagina defualt (no tiene header)      
      report.list(:movements_list) do |list|
        list.add_row do |row|
          row.values line_number: index + 1,
            date: movement.created_at.strftime("%d/%m/%Y"),
            lot: movement.lot_stock.lot_code,
            movement: movement.order.class.model_name.human,
            origin_name: movement.order_origin_name,
            destiny_name: movement.order_destiny_name,
            received_quantity: movement.adds? ? movement.quantity : 0,
            delivered_quantity: movement.adds? ? 0 : movement.quantity
        end
      end
    end
    
    report.page[:lots_title].value(@lot_stocks.count.to_s+" lotes en stock")

    @lot_stocks.each_with_index do |lot_stock, index|
      # Luego de que la primer pagina ya halla sido rellenada, agregamos la pagina defualt (no tiene header)      
      report.list(:lot_stocks_list) do |list|
        list.add_row do |row|
          row.values line_number: index + 1,
            lot: lot_stock.lot_code,
            laboratory: lot_stock.lot_laboratory_name,
            expiry_date: lot_stock.lot_expiry_date_string,
            status: lot_stock.lot_status.humanize,
            quantity: lot_stock.quantity,
            reserved_quantity: lot_stock.reserved_quantity,
            total_quantity: lot_stock.total_quantity 
        end
      end
    end

    # A cada pagina le agregamos el pie de pagina
    report.pages.each do |page|
      page[:page_count] = report.page_count
    end

    report.generate
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_receipt
      @receipt = params[:id].present? ? Receipt.find(params[:id]) : Receipt.new
      @sectors = @receipt.provider_sector.present? ? @receipt.provider_sector.establishment.sectors : []
      @receipt_products = @receipt.receipt_products.present? ? @receipt.receipt_products : @receipt.receipt_products.build
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def receipt_params
      params.require(:receipt).permit(
        :provider_sector_id,
        :observation,
        receipt_products_attributes: 
        [
          :id,
          :product_id,
          :receipt_id,
          :expiry_date, 
          :quantity,
          :provenance_id,
          :lot_code,
          :laboratory_id,
          :lot_id,
          :lot_stock_id,
          :_destroy
        ]
      )
    end

    def receiving?
      submit = params[:commit]
      return submit == "receive"
    end
end
