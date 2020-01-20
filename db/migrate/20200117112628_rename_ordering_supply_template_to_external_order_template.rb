class RenameOrderingSupplyTemplateToExternalOrderTemplate < ActiveRecord::Migration[5.2]
  def change
    rename_table :ordering_supply_templates, :external_order_templates
  end
end
