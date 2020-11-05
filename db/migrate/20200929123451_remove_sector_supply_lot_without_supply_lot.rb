class RemoveSectorSupplyLotWithoutSupplyLot < ActiveRecord::Migration[5.2]
  def change
    SectorSupplyLot.find_each do |sector_lot|
      unless SupplyLot.where(id: sector_lot.supply_lot_id).present?
        sector_lot.destroy
      end
    end
  end
end
