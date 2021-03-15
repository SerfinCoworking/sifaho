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
    @internal_order_template = InternalOrderTemplate.new(order_type: 'solicitud')
    @sectors = current_user.establishment.sectors
  end

  # GET /internal_order_templates/new_provider
  def new_provider
    authorize InternalOrderTemplate
    @internal_order_template = InternalOrderTemplate.new(order_type: 'provision')
    @sectors = current_user.establishment.sectors
  end

  # GET /internal_order_templates/1/edit
  def edit
    authorize @internal_order_template
    @sectors = current_user.establishment.sectors
  end

  # GET /internal_order_templates/1/edit_provider
  def edit_provider
    authorize @internal_order_template
    @sectors = current_user.establishment.sectors
  end

  # POST /internal_order_templates
  # POST /internal_order_templates.json
  def create
    authorize InternalOrderTemplate
    @internal_order_template = InternalOrderTemplate.new(internal_order_template_params)
    @internal_order_template.owner_sector = current_user.sector
    @internal_order_template.created_by = current_user

    respond_to do |format|
      @internal_order_template.save!
      begin
        format.html { redirect_to @internal_order_template, notice: 'La plantilla se ha creado correctamente.' }
      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @sectors = current_user.establishment.sectors
        format.html { render :new }
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
      params.require(:internal_order_template).permit(:name,
        :owner_sector_id,
        :destination_sector_id,
        :observation,
        :order_type,
        internal_order_product_templates_attributes: [ 
          :id,
          :product_id,
          :_destroy 
        ]
      )
    end
end
