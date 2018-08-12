class AddAttributesToSectorSupplyLots < ActiveRecord::Migration[5.1]
  def change
    add_column :sector_supply_lots, :status, :integer, default: 0
    add_column :sector_supply_lots, :quantity, :integer
    add_column :sector_supply_lots, :initial_quantity, :integer
    add_timestamps :sector_supply_lots, null: true

    long_ago = DateTime.new(2000, 1, 1)
    SectorSupplyLot.update_all(created_at: long_ago, updated_at: long_ago)

    change_column_null :sector_supply_lots, :created_at, false
    change_column_null :sector_supply_lots, :updated_at, false
  end
end
