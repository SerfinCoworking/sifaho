class CreateSectorSupplyLots < ActiveRecord::Migration[5.1]
  def change
    create_table :sector_supply_lots do |t|
      t.integer :sector_id
      t.integer :supply_lot_id
      t.integer :quantity
      t.integer :initial_quantity
      t.integer :status, default: 0

      t.timestamps
    end
    add_index :sector_supply_lots, %I(sector_id supply_lot_id), name: :sector_supply_lot
    add_index :sector_supply_lots, :deleted_at
    add_column :sector_supply_lots, :deleted_at, :datetime
  end
end
