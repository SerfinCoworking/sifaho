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
  end
end
