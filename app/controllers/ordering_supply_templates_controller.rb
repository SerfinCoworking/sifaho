class OrderingSupplyTemplatesController < ApplicationController
  before_action :set_ordering_supply_template, only: [:show, :edit, :update, :destroy, :delete, :use_applicant, :use_provider, :edit_provider]

  # GET /ordering_supply_templates
  # GET /ordering_supply_templates.json
  def index
    authorize OrderingSupplyTemplate
    @applicant_templates = OrderingSupplyTemplate.where(owner_sector: current_user.sector).solicitud
    @provider_templates = OrderingSupplyTemplate.where(owner_sector: current_user.sector).despacho
  end

  # GET /ordering_supply_templates/1
  # GET /ordering_supply_templates/1.json
  def show
    authorize @ordering_supply_template
  end

  # GET /ordering_supply_templates/new
  def new
    authorize OrderingSupplyTemplate
    @ordering_supply_template = OrderingSupplyTemplate.new
    @destination_sectors = current_user.establishment.sectors
  end

  # GET /ordering_supply_templates/new_provider
  def new_provider
    authorize OrderingSupplyTemplate
    @ordering_supply_template = OrderingSupplyTemplate.new
    @order_type = 'despacho'
    @destination_sectors = current_user.establishment.sectors
  end

  # GET /ordering_supply_templates/1/edit
  def edit
    authorize @ordering_supply_template
    @destination_sectors = current_user.establishment.sectors
  end

  # GET /ordering_supply_templates/1/edit_provider
  def edit_provider
    authorize @ordering_supply_template
    @destination_sectors = current_user.establishment.sectors
  end

  # POST /ordering_supply_templates
  # POST /ordering_supply_templates.json
  def create
    authorize OrderingSupplyTemplate
    @ordering_supply_template = OrderingSupplyTemplate.new(ordering_supply_template_params)
    @ordering_supply_template.owner_sector = current_user.sector
    @ordering_supply_template.created_by = current_user

    respond_to do |format|
      if @ordering_supply_template.save!
        format.html { redirect_to @ordering_supply_template, notice: 'La plantilla se ha creado correctamente.' }
        format.json { render :show, status: :created, location: @ordering_supply_template }
      else
        @destination_sectors = current_user.establishment.sectors
        format.html { render :new }
        format.json { render json: @ordering_supply_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ordering_supply_templates/1
  # PATCH/PUT /ordering_supply_templates/1.json
  def update
    authorize @ordering_supply_template
    respond_to do |format|
      if @ordering_supply_template.update(ordering_supply_template_params)
        format.html { redirect_to @ordering_supply_template, notice: 'La plantilla se ha editado correctamente.' }
        format.json { render :show, status: :ok, location: @ordering_supply_template }
      else
        format.html { render :edit }
        format.json { render json: @ordering_supply_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /ordering_supply_templates/:id/use_applicant(.:format) 
  def use_applicant
    authorize @ordering_supply_template
    @ordering_supply = OrderingSupply.new
    @ordering_supply.provider_sector = @ordering_supply_template.destination_sector
    @ordering_supply_template.ordering_supply_template_supplies.joins(:supply).order("name").each do |iots|
      @ordering_supply.quantity_ord_supply_lots.build(supply_id: iots.supply_id)
    end
    @order_type = 'solicitud_abastecimiento'
    @sectors = Sector
      .select(:id, :name)
      .with_establishment_id(@ordering_supply_template.destination_establishment_id)
      .where.not(id: current_user.sector_id)
    respond_to do |format|
      flash[:notice] = "La plantilla se ha utilizado correctamente."
      format.html { render "ordering_supplies/new_applicant" }
    end
  end

  # GET /ordering_supply_templates/:id/use_provider(.:format) 
  def use_provider
    authorize @ordering_supply_template
    @ordering_supply = OrderingSupply.new
    @ordering_supply.applicant_sector = @ordering_supply_template.destination_sector
    @ordering_supply_template.ordering_supply_template_supplies.joins(:supply).order("name").each do |iots|
      @ordering_supply.quantity_ord_supply_lots.build(supply_id: iots.supply_id)
    end
    @order_type = 'despacho'
    @sectors = Sector
      .select(:id, :name)
      .with_establishment_id(@ordering_supply_template.destination_establishment_id)
      .where.not(id: current_user.sector_id)
    respond_to do |format|
      flash[:notice] = "La plantilla se ha utilizado correctamente."
      format.html { render "ordering_supplies/new" }
    end
  end

  # DELETE /ordering_supply_templates/1
  # DELETE /ordering_supply_templates/1.json
  def destroy
    authorize @ordering_supply_template
    @ordering_supply_template.destroy
    respond_to do |format|
      format.html { redirect_to ordering_supply_templates_url, notice: 'La plantilla se ha eliminado correctamente.' }
      format.json { head :no_content }
    end
  end

  # GET /ordering_supply_templates/1/delete
  def delete
    authorize @ordering_supply_template
    respond_to do |format|
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ordering_supply_template
      @ordering_supply_template = OrderingSupplyTemplate.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ordering_supply_template_params
      params.require(:ordering_supply_template).permit(:name, :owner_sector_id, :destination_sector_id, :destination_establishment_id, :observation, :order_type,
        ordering_supply_template_supplies_attributes: [ :id, :supply_id, :_destroy ]
      )
    end
end
