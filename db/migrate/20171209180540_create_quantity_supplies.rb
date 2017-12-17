class CreateQuantitySupplies < ActiveRecord::Migration[5.1]
  def change
    create_table :quantity_supplies do |t|
      t.integer :quantifiable_id
      t.integer :supply_id
      t.string :quantifiable_type
      t.integer :quantity

      t.timestamps
    end
  end
end
