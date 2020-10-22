class RemoveStockFromSectorSupplyLots < ActiveRecord::Migration[5.2]
  def change
    remove_reference :sector_supply_lots, :stock, index: true
  end
end
