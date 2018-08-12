class AddDeletedAtToSectorSupplyLots < ActiveRecord::Migration[5.1]
  def change
    add_column :sector_supply_lots, :deleted_at, :datetime
    add_index :sector_supply_lots, :deleted_at
  end
end
