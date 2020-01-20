class ExternalOrderTemplatesController < ApplicationController
  before_action :set_external_order_template, only: [:show, :edit, :update, :destroy, :delete, :use_applicant, :use_provider, :edit_provider]

  # GET /external_order_templates
  # GET /external_order_templates.json
  def index
    authorize ExternalOrderTemplate
    @applicant_templates = ExternalOrderTemplate.where(owner_sector: current_user.sector).solicitud
    @provider_templates = ExternalOrderTemplate.where(owner_sector: current_user.sector).despacho
  end

  # GET /external_order_templates/1
  # GET /external_order_templates/1.json
  def show
    authorize @external_order_template
  end

  # GET /external_order_templates/new
  def new
    authorize ExternalOrderTemplate
    @external_order_template = ExternalOrderTemplate.new
    @order_type = 'solicitud_abastecimiento'
    @destination_sectors = current_user.establishment.sectors
  end

  # GET /external_order_templates/new_provider
  def new_provider
    authorize ExternalOrderTemplate
    @external_order_template = ExternalOrderTemplate.new
    @order_type = 'despacho'
    @destination_sectors = current_user.establishment.sectors
  end

  # GET /external_order_templates/1/edit
  def edit
    authorize @external_order_template
    @destination_sectors = Sector.with_establishment_id(@external_order_template.destination_sector.establishment_id)
  end

  # GET /external_order_templates/1/edit_provider
  def edit_provider
    authorize @external_order_template
    @destination_sectors = Sector.with_establishment_id(@external_order_template.destination_sector.establishment_id)
  end

  # POST /external_order_templates
  # POST /external_order_templates.json
  def create
    authorize ExternalOrderTemplate
    @external_order_template = ExternalOrderTemplate.new(external_order_template_params)
    @external_order_template.owner_sector = current_user.sector
    @external_order_template.created_by = current_user

    respond_to do |format|
      if @external_order_template.save!
        format.html { redirect_to @external_order_template, notice: 'La plantilla se ha creado correctamente.' }
        format.json { render :show, status: :created, location: @external_order_template }
      else
        @destination_sectors = current_user.establishment.sectors
        format.html { render :new }
        format.json { render json: @external_order_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /external_order_templates/1
  # PATCH/PUT /external_order_templates/1.json
  def update
    authorize @external_order_template
    respond_to do |format|
      if @external_order_template.update(external_order_template_params)
        format.html { redirect_to @external_order_template, notice: 'La plantilla se ha editado correctamente.' }
        format.json { render :show, status: :ok, location: @external_order_template }
      else
        format.html { render :edit }
        format.json { render json: @external_order_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /external_order_templates/:id/use_applicant(.:format) 
  def use_applicant
    authorize @external_order_template
    @external_order = ExternalOrder.new
    @external_order.provider_sector = @external_order_template.destination_sector
    @external_order_template.external_order_template_supplies.joins(:supply).order("name").each do |iots|
      @external_order.quantity_ord_supply_lots.build(supply_id: iots.supply_id)
    end
    @order_type = 'solicitud_abastecimiento'
    @sectors = Sector
      .select(:id, :name)
      .with_establishment_id(@external_order_template.destination_establishment_id)
      .where.not(id: current_user.sector_id)
    respond_to do |format|
      flash[:notice] = "La plantilla se ha utilizado correctamente."
      format.html { render "external_orders/new_applicant" }
    end
  end

  # GET /external_order_templates/:id/use_provider(.:format) 
  def use_provider
    authorize @external_order_template
    @external_order = ExternalOrder.new
    @external_order.applicant_sector = @external_order_template.destination_sector
    @external_order_template.external_order_template_supplies.joins(:supply).order("name").each do |iots|
      @external_order.quantity_ord_supply_lots.build(supply_id: iots.supply_id)
    end
    @order_type = 'despacho'
    @sectors = Sector
      .select(:id, :name)
      .with_establishment_id(@external_order_template.destination_establishment_id)
      .where.not(id: current_user.sector_id)
    respond_to do |format|
      flash[:notice] = "La plantilla se ha utilizado correctamente."
      format.html { render "external_orders/new" }
    end
  end

  # DELETE /external_order_templates/1
  # DELETE /external_order_templates/1.json
  def destroy
    authorize @external_order_template
    @external_order_template.destroy
    respond_to do |format|
      format.html { redirect_to external_order_templates_url, notice: 'La plantilla se ha eliminado correctamente.' }
      format.json { head :no_content }
    end
  end

  # GET /external_order_templates/1/delete
  def delete
    authorize @external_order_template
    respond_to do |format|
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_external_order_template
      @external_order_template = ExternalOrderTemplate.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def external_order_template_params
      params.require(:external_order_template).permit(:name, :owner_sector_id, :destination_sector_id, :destination_establishment_id, :observation, :order_type,
        external_order_template_supplies_attributes: [ :id, :supply_id, :_destroy ]
      )
    end
end
