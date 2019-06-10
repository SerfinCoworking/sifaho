class ChangeDefaultQuantityToSectorSupplyLot < ActiveRecord::Migration[5.2]
  def change
    change_column :sector_supply_lots, :quantity, :integer, default: 0
  end
end
