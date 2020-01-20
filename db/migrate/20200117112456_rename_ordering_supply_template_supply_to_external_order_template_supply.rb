class RenameOrderingSupplyTemplateSupplyToExternalOrderTemplateSupply < ActiveRecord::Migration[5.2]
  def change
    rename_table :ordering_supply_template_supplies, :external_order_template_supplies
  end
end
