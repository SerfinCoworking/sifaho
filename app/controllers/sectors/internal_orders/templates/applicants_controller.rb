class Sectors::InternalOrders::Templates::ApplicantsController < Sectors::InternalOrders::Templates::TemplatesController

  # GET /sectors/internal_orders/templates/applicants/new
  def new
    authorize InternalOrderTemplate
    @internal_order_template = InternalOrderTemplate.new(order_type: 'solicitud')
    @sectors = current_user.establishment.sectors
    @internal_order_template.internal_order_product_templates.build
  end

  # GET /sectors/internal_orders/templates/applicants/1/edit
  def edit
    policy(:internal_order_template_applicant).edit?(@internal_order_template)
    @sectors = current_user.establishment.sectors
  end

  # POST /sectors/internal_orders/templates/applicants
  # POST /sectors/internal_orders/templates/applicants.json
  def create
    authorize InternalOrderTemplate
    @internal_order_template = InternalOrderTemplate.new(internal_order_template_params)
    @internal_order_template.owner_sector = current_user.sector
    @internal_order_template.created_by = current_user

    respond_to do |format|
      @internal_order_template.save!
      begin
        format.html { redirect_to internal_orders_templates_applicant_url(@internal_order_template), notice: 'La plantilla se ha creado correctamente.' }
      rescue ArgumentError => e
        flash[:alert] = e.message
      rescue ActiveRecord::RecordInvalid
      ensure
        @sectors = current_user.establishment.sectors
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /sectors/internal_orders/templates/applicants/1
  # PATCH/PUT /sectors/internal_orders/templates/applicants/1.json
  def update
    authorize @internal_order_template
    respond_to do |format|
      if @internal_order_template.update(internal_order_template_params)
        format.html { redirect_to internal_orders_templates_applicant_url(@internal_order_template), notice: 'La plantilla se ha editado correctamente.' }
        format.json { render :show, status: :ok, location: @internal_order_template }
      else
        @sectors = current_user.establishment.sectors
        format.html { render :edit }
        format.json { render json: @internal_order_template.errors, status: :unprocessable_entity }
      end
    end
  end

  def build_from_template
    respond_to do |format|
      @internal_order = InternalOrder.create(provider_sector_id: @internal_order_template.destination_sector_id,
                                             applicant_sector: current_user.sector,
                                             requested_date: DateTime.now,
                                             status: 'solicitud_auditoria',
                                             observation: @internal_order_template.observation,
                                             order_type: @internal_order_template.order_type)
      format.html { redirect_to edit_products_internal_orders_applicant_path(id: @internal_order, template: @internal_order_template) }
    end
  end
end
