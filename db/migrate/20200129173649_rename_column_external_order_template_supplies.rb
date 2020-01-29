class RenameColumnExternalOrderTemplateSupplies < ActiveRecord::Migration[5.2]
  def change
    rename_column :external_order_template_supplies, :ordering_supply_template_id, :external_order_template_id
  end
end
