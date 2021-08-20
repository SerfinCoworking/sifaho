class Establishments::ExternalOrders::Templates::ApplicantsController < Establishments::ExternalOrders::Templates::TemplatesController

  # GET /external_order_templates/new
  def new
    authorize ExternalOrderTemplate
    @external_order_template = ExternalOrderTemplate.new(order_type: 'solicitud')
    @external_order_template.external_order_product_templates.build
    @sectors = []
  end
  
  # GET /external_order_templates/1/edit
  def edit
    policy(:external_order_template_applicant).edit?(@external_order_template)
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
        format.html { redirect_to external_orders_templates_applicant_url(@external_order_template), notice: 'La plantilla se ha creado correctamente.' }
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
        format.html { redirect_to external_orders_templates_applicant_url(@external_order_template), notice: 'La plantilla se ha editado correctamente.' }
      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @sectors = @external_order_template.destination_sector.present? ? @external_order_template.destination_establishment.sectors : []
        format.html { render :edit }
      end
    end
  end
end
