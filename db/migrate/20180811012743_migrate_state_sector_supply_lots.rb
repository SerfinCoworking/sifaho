class MigrateStateSectorSupplyLots < ActiveRecord::Migration[5.1]
  SectorSupplyLot.find_each do |ssl|
    supply = SupplyLot.find(ssl.supply_lot_id)
    ssl.status = supply.status
    ssl.quantity = supply.quantity
    ssl.initial_quantity = supply.initial_quantity
    ssl.save!
  end
end
