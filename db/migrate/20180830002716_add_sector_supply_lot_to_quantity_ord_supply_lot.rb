class AddSectorSupplyLotToQuantityOrdSupplyLot < ActiveRecord::Migration[5.1]
  def change
    add_reference :quantity_ord_supply_lots, :sector_supply_lot, index: true
  end
end
