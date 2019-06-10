class SetDefaultInitialQuantityToSectorSupplyLot < ActiveRecord::Migration[5.2]
  def change
    change_column :sector_supply_lots, :initial_quantity, :integer, default: 0
  end
end
