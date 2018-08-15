class CreateSupplyLots < ActiveRecord::Migration[5.1]
  def change
    create_table :supply_lots do |t|
      t.string :code
      t.string :supply_name
      t.datetime :expiry_date
      t.datetime :date_received
      t.integer :quantity
      t.integer :initial_quantity
      t.integer :status, default: 0

      t.timestamps
    end
    add_column :supply_lots, :deleted_at, :datetime
    add_index :supply_lots, :deleted_at
    add_reference :supply_lots, :sector, foreign_key: true
    add_column :supply_lots, :lot_code, :string, :limit => 20
    add_index :supply_lots, :lot_code, unique: true
  end
end
