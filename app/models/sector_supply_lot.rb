class SectorSupplyLot < ApplicationRecord
  belongs_to :sector
  belongs_to :supply_lot
end
