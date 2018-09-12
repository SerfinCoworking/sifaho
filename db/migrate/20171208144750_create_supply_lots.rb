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
    add_reference :supply_lots, :supply, foreign_key: true
    add_column :supply_lots, :deleted_at, :datetime
    add_index :supply_lots, :deleted_at
    add_column :supply_lots, :lot_code, :string, :limit => 20
    add_reference :supply_lots, :laboratory, foreign_key: true
    add_index :supply_lots, [:lot_code, :laboratory_id], unique: true
  end
end
