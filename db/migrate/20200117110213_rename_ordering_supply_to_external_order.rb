class RenameOrderingSupplyToExternalOrder < ActiveRecord::Migration[5.2]
  def change
    rename_table :ordering_supplies, :external_orders
  end
end
