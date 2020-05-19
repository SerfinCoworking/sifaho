class CreateSectorSupplyLots < ActiveRecord::Migration[5.1]
  def change
    create_table :sector_supply_lots do |t|
      t.integer :sector_id
      t.integer :supply_lot_id
      t.integer :quantity, default: 0
      t.integer :initial_quantity, default: 0
      t.integer :status, default: 0
      t.references :stock, index: true

      t.timestamps
    end
    add_index :sector_supply_lots, %I(sector_id supply_lot_id), name: :sector_supply_lot
    add_column :sector_supply_lots, :deleted_at, :datetime
    add_index :sector_supply_lots, :deleted_at
  end
end