class CreateQuantitySupplyLots < ActiveRecord::Migration[5.1]
  def change
    create_table :quantity_supply_lots do |t|
      t.integer :supply_lot_id
      t.references :quantifiable, polymorphic: true, index: { name: 'quant_sup_lot_poly' }
      t.integer :quantity

      t.timestamps
    end
  end
end
