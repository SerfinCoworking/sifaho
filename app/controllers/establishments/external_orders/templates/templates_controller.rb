class Establishments::ExternalOrders::Templates::TemplatesController < ApplicationController

  before_action :set_external_order_template, only: %i[show edit update destroy delete use_applicant use_provider
                                                       edit_provider]

  # GET /external_order_templates
  # GET /external_order_templates.json
  def index
    authorize ExternalOrderTemplate
    @applicant_templates = ExternalOrderTemplate.where(owner_sector: current_user.sector).solicitud
    @provider_templates = ExternalOrderTemplate.where(owner_sector: current_user.sector).provision
  end

  # GET /external_order_templates/1
  # GET /external_order_templates/1.json
  def show
    authorize @external_order_template
    respond_to do |format|
      format.html
      format.pdf do
        pdf = ReportServices::ExternalOrderTemplateReportService.new(current_user, @external_order_template).call
        send_data pdf, filename: "Plantilla_#{@external_order_template.order_type}.pdf", type: 'application/pdf', disposition: 'inline'
      end
    end
  end

  # GET /external_order_templates/new
  def new
    authorize ExternalOrderTemplate
    @external_order_template = ExternalOrderTemplate.new(order_type: 'solicitud')
    @external_order_template.external_order_product_templates.build
    @sectors = []
  end

  # GET /external_order_templates/new_provider
  def new_provider
    authorize ExternalOrderTemplate
    @external_order_template = ExternalOrderTemplate.new(order_type: 'provision')
    @external_order_template.external_order_product_templates.build
    @sectors = []
  end

  # GET /external_order_templates/1/edit
  def edit
    authorize @external_order_template
    @sectors = @external_order_template.destination_sector.present? ? @external_order_template.destination_establishment.sectors : []
  end

  # GET /external_order_templates/1/edit_provider
  def edit_provider
    authorize @external_order_template
    @sectors = @external_order_template.destination_sector.present? ? @external_order_template.destination_establishment.sectors : []
  end

  # POST /external_order_templates
  # POST /external_order_templates.json
  def create
    authorize ExternalOrderTemplate
    @external_order_template = ExternalOrderTemplate.new(external_order_template_params)
    @external_order_template.owner_sector = current_user.sector
    @external_order_template.created_by = current_user

    respond_to do |format|
      begin
        @external_order_template.save!
        format.html { redirect_to @external_order_template, notice: 'La plantilla se ha creado correctamente.' }
      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @sectors = @external_order_template.destination_sector.present? ? @external_order_template.destination_establishment.sectors : []
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /external_order_templates/1
  # PATCH/PUT /external_order_templates/1.json
  def update
    authorize @external_order_template

    respond_to do |format|
      begin
        @external_order_template.update!(external_order_template_params)
        format.html { redirect_to @external_order_template, notice: 'La plantilla se ha editado correctamente.' }
      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @sectors = @external_order_template.destination_sector.present? ? @external_order_template.destination_establishment.sectors : []
        format.html { render :edit }
      end
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
    params.require(:external_order_template).permit(
      :name,
      :owner_sector_id,
      :destination_sector_id,
      :destination_establishment_id,
      :observation, 
      :order_type,
      external_order_product_templates_attributes:
      [ 
        :id,
        :product_id,
        :_destroy 
      ]
    )
  end
end
