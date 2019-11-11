class SetDefultOrderTypeToInternalOrderTemplates < ActiveRecord::Migration[5.2]
  def change
    change_column :internal_order_templates, :order_type, :integer, default: 0 
  end
end
