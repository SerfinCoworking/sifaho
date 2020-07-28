class InternalOrderTemplatesController < ApplicationController
  before_action :set_internal_order_template, only: [:show, :edit, :update, :destroy, :delete, :use_applicant, :use_provider, :edit_provider]

  # GET /internal_order_templates
  # GET /internal_order_templates.json
  def index
    authorize InternalOrderTemplate
    @applicant_templates = InternalOrderTemplate.where(owner_sector: current_user.sector).solicitud
    @provider_templates = InternalOrderTemplate.where(owner_sector: current_user.sector).provision
  end

  # GET /internal_order_templates/1
  # GET /internal_order_templates/1.json
  def show
    authorize @internal_order_template
  end

  # GET /internal_order_templates/new
  def new
    authorize InternalOrderTemplate
    @internal_order_template = InternalOrderTemplate.new
    @order_type = 'solicitud'
    @destination_sectors = current_user.establishment.sectors
  end

  # GET /internal_order_templates/new_provider
  def new_provider
    authorize InternalOrderTemplate
    @internal_order_template = InternalOrderTemplate.new
    @order_type = 'provision'
    @destination_sectors = current_user.establishment.sectors
  end

  # GET /internal_order_templates/1/edit
  def edit
    authorize @internal_order_template
    @order_type = 'solicitud'
    @destination_sectors = current_user.establishment.sectors
  end

  # GET /internal_order_templates/1/edit_provider
  def edit_provider
    authorize @internal_order_template
    @order_type = 'provision'
    @destination_sectors = current_user.establishment.sectors
  end

  # POST /internal_order_templates
  # POST /internal_order_templates.json
  def create
    authorize InternalOrderTemplate
    @internal_order_template = InternalOrderTemplate.new(internal_order_template_params)
    @internal_order_template.owner_sector = current_user.sector
    @internal_order_template.created_by = current_user

    respond_to do |format|
      if @internal_order_template.save!
        format.html { redirect_to @internal_order_template, notice: 'La plantilla se ha creado correctamente.' }
        format.json { render :show, status: :created, location: @internal_order_template }
      else
        @destination_sectors = current_user.establishment.sectors
        format.html { render :new }
        format.json { render json: @internal_order_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /internal_order_templates/1
  # PATCH/PUT /internal_order_templates/1.json
  def update
    authorize @internal_order_template
    respond_to do |format|
      if @internal_order_template.update(internal_order_template_params)
        format.html { redirect_to @internal_order_template, notice: 'La plantilla se ha editado correctamente.' }
        format.json { render :show, status: :ok, location: @internal_order_template }
      else
        format.html { render :edit }
        format.json { render json: @internal_order_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /internal_order_templates/:id/use_applicant(.:format) 
  def use_applicant
    authorize @internal_order_template
    @internal_order = InternalOrder.new
    @internal_order.provider_sector = @internal_order_template.destination_sector
    @internal_order_template.internal_order_template_supplies.joins(:supply).order("name").each do |iots|
      @internal_order.quantity_ord_supply_lots.build(supply_id: iots.supply_id)
    end
    @internal_order.quantity_ord_supply_lots.joins(:supply).order("name")
    @order_type = 'solicitud'
    @provider_sectors = Sector
      .select(:id, :name)
      .with_establishment_id(current_user.sector.establishment_id)
      .where.not(id: current_user.sector_id).as_json
    respond_to do |format|
      flash[:notice] = "La plantilla se ha utilizado correctamente."
      format.html { render "internal_orders/new_applicant" }
    end
  end

  # GET /internal_order_templates/:id/use_provider(.:format) 
  def use_provider
    authorize @internal_order_template
    @internal_order = InternalOrder.new
    @internal_order.applicant_sector = @internal_order_template.destination_sector
    @internal_order_template.internal_order_template_supplies.joins(:supply).order("name").each do |iots|
      @internal_order.quantity_ord_supply_lots.build(supply_id: iots.supply_id)
    end
    @internal_order.quantity_ord_supply_lots.joins(:supply).order("name")
    @order_type = 'provision'
    @applicant_sectors = Sector
      .select(:id, :name)
      .with_establishment_id(current_user.sector.establishment_id)
      .where.not(id: current_user.sector_id).as_json
    respond_to do |format|
      flash[:notice] = "La plantilla se ha utilizado correctamente."
      format.html { render "internal_orders/new_provider" }
    end
  end

  # DELETE /internal_order_templates/1
  # DELETE /internal_order_templates/1.json
  def destroy
    authorize @internal_order_template
    @internal_order_template.destroy
    respond_to do |format|
      format.html { redirect_to internal_order_templates_url, notice: 'La plantilla se ha eliminado correctamente.' }
      format.json { head :no_content }
    end
  end

  # GET /internal_order_templates/1/delete
  def delete
    authorize @internal_order_template
    respond_to do |format|
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_internal_order_template
      @internal_order_template = InternalOrderTemplate.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def internal_order_template_params
      params.require(:internal_order_template).permit(:name, :owner_sector_id, :destination_sector_id, :observation, :order_type,
        internal_order_template_supplies_attributes: [ :id, :supply_id, :_destroy ]
      )
    end
end
