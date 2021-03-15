class MoveExternalOrderTemplateSuppliesToExternalOrderProductTemplates < ActiveRecord::Migration[5.2]
  def up
    ExternalOrderTemplateSupply.find_each do |eots|
      ExternalOrderProductTemplate.create(product_id: eots.supply_id, external_order_template_id: eots.external_order_template_id, created_at: eots.created_at, updated_at: eots.updated_at)
    end
  end

  def down
    
  end
end
