class CreateQuantityOrdSupplyLots < ActiveRecord::Migration[5.1]
  def change
    create_table :quantity_ord_supply_lots do |t|
      t.integer :supply_lot
      t.references :quantifiable, polymorphic: true, index: { name: 'quant_ord_sup_lot_poly' }
      t.integer :requested_quantity
      t.integer :delivered_quantity

      t.timestamps
    end
  end
end
