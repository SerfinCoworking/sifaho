class AddSectorSupplyLotToQuantitySupplyLot < ActiveRecord::Migration[5.1]
  def change
    add_column :quantity_supply_lots, :sector_supply_lot_id, :integer
    remove_column :quantity_supply_lots, :supply_lot_id
  end
end
