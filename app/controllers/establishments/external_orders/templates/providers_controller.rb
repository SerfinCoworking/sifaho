class Establishments::ExternalOrders::Templates::ProvidersController < Establishments::ExternalOrders::Templates::TemplatesController
  # GET /external_order_templates/new
  def new
    authorize ExternalOrderTemplate
    @external_order_template = ExternalOrderTemplate.new(order_type: 'provision')
    @external_order_template.external_order_product_templates.build
    @sectors = []
  end

  # GET /external_order_templates/1/edit
  def edit
    policy(:external_order_template_provider).edit?(@external_order_template)
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
        format.html { redirect_to external_orders_templates_provider_url(@external_order_template), notice: 'La plantilla se ha creado correctamente.' }
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
        format.html { redirect_to external_orders_templates_provider_url(@external_order_template), notice: 'La plantilla se ha editado correctamente.' }
      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @sectors = @external_order_template.destination_sector.present? ? @external_order_template.destination_establishment.sectors : []
        format.html { render :edit }
      end
    end
  end

  def build_from_template
    respond_to do |format|
      @external_order = ExternalOrder.create(applicant_sector_id: @external_order_template.destination_sector_id,
                                             provider_sector: current_user.sector,
                                             requested_date: DateTime.now,
                                             status: 'proveedor_auditoria',
                                             provider_observation: @external_order_template.provider_observation,
                                             order_type: @external_order_template.order_type)
      format.html { redirect_to edit_products_external_orders_provider_path(id: @external_order, template: @external_order_template) }
    end
  end
end
