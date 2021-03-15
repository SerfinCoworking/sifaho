class MoveInternalOrderTemplateSuppliesToInternalOrderProductTemplatas < ActiveRecord::Migration[5.2]
  def up
    InternalOrderTemplateSupply.find_each do |eots|
      InternalOrderProductTemplate.create(product_id: eots.supply_id, internal_order_template_id: eots.internal_order_template_id, created_at: eots.created_at, updated_at: eots.updated_at)
    end
  end

  def down
    
  end
end
