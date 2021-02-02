class ReceiptsController < ApplicationController
  before_action :set_receipt, only: [:show, :new, :edit, :update, :delete, :destroy]
  before_action :set_highlight_row, only: [:show]

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
  end

  # GET /receipts/new
  def new
    authorize Receipt
  end

  # GET /receipts/1/edit
  def edit
    authorize @receipt
  end

  # POST /receipts
  # POST /receipts.json
  def create
    @receipt = Receipt.new(receipt_params)
    authorize @receipt
    respond_to do |format|
      @receipt.applicant_sector = current_user.sector
      @receipt.created_by = current_user
      @receipt.code = @receipt.applicant_sector.name[0..3].upcase+'rec'+Receipt.maximum(:id).to_i.next.to_s
      
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
    
    def set_highlight_row
      params[:resaltar].present? ? @highlight_row = params[:resaltar].to_i : @highlight_row = -1
    end
end
