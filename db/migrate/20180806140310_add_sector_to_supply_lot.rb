class AddSectorToSupplyLot < ActiveRecord::Migration[5.1]
  def change
    add_reference :supply_lots, :sector, foreign_key: true
  end
end
