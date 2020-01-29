class AddStockToSectorSupplyLot < ActiveRecord::Migration[5.2]
  def change
    add_reference :sector_supply_lots, :stock, foreign_key: true
  end
end
