class CreateQuantitySupplies < ActiveRecord::Migration[5.1]
  def change
    create_table :quantity_supplies do |t|
      t.integer :supply_id
      t.references :quantifiable, polymorphic: true, index: { name: 'quant_sup_poly' }
      t.integer :quantity

      t.timestamps
    end
  end
end
