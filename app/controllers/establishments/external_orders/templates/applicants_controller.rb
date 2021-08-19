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
    authorize @external_order_template
    @sectors = @external_order_template.destination_sector.present? ? @external_order_template.destination_establishment.sectors : []
  end

end
