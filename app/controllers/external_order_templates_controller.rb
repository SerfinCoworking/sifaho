class ExternalOrderTemplatesController < ApplicationController
  before_action :set_external_order_template, only: [:show, :edit, :update, :destroy, :delete, :use_applicant, :use_provider, :edit_provider]

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
        send_data generate_report(),
          filename: "plantilla_#{@external_order_template.order_type}_establecimiento.pdf",
          type: 'application/pdf',
          disposition: 'inline'
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

    def generate_report()
      report = Thinreports::Report.new layout: File.join(Rails.root, 'app', 'reports', 'external_order_template', 'first_page.tlf')
      report.use_layout File.join(Rails.root, 'app', 'reports', 'external_order_template', 'second_page.tlf'), id: :other_page
      
      # Comenzamos con la pagina principal
      report.start_new_page

      report.page[:template_name] = @external_order_template.name
      report.page[:efector] = @external_order_template.destination_sector.sector_and_establishment
      report.page[:username].value("DNI: "+current_user.dni.to_s+", "+current_user.full_name)
      
      @external_order_template.external_order_product_templates.joins(:product).order("name").each do |iots|
        if report.page_count == 1 && report.list.overflow?
          report.start_new_page layout: :other_page
        end

        report.list do |list|
          list.add_row do |row|
            row.item(:product_code).value(iots.product_code)
            row.item(:product_name).value(iots.product_name)
            row.item(:unity_name).value(iots.product.unity_name)
          end
        end
      end
      
      report.pages.each do |page|
        page[:title] = "Plantilla de #{@external_order_template.order_type} de establecimiento"
        page[:requested_date] = DateTime.now.strftime("%d/%m/%Y")
        page[:page_count] = report.page_count
      end
  
      report.generate
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
