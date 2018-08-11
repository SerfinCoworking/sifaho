class MigrateDatabaseState < ActiveRecord::Migration[5.1]
  ActiveRecord::Base.transaction do
    SupplyLot.where.not(sector_id: nil).find_each do |supply_lot|
      next if SectorSupplyLot.find_by(supply_lot_id: supply_lot.id, sector_id: supply_lot.sector_id)
      SectorSupplyLot.create!(supply_lot_id: supply_lot.id, sector_id: supply_lot.sector_id)
    end
  end
end
