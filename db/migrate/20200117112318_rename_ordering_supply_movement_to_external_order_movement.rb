class RenameOrderingSupplyMovementToExternalOrderMovement < ActiveRecord::Migration[5.2]
  def change
    rename_table :ordering_supply_movements, :external_order_movements
  end
end
