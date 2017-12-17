class CreateSupplies < ActiveRecord::Migration[5.1]
  def change
    create_table :supplies do |t|
      t.string :name
      t.integer :quantity
      t.datetime :expiry_date
      t.datetime :date_received

      t.timestamps
    end
  end
end
