class CreateQuantityOrdSupplyLots < ActiveRecord::Migration[5.1]
  def change
    create_table :quantity_ord_supply_lots do |t|
      t.integer :supply_lot
      t.string :lot_code
      t.references :quantifiable, polymorphic: true, index: { name: 'quant_ord_sup_lot_poly' }
      t.integer :requested_quantity
      t.integer :delivered_quantity
      t.integer :status, default: 0
      t.references :supply, index: true
      t.references :sector_supply_lot, index: true
      t.references :supply_lot, index: true
      t.references :laboratory, index: true
      t.text :observation

      t.datetime :expiry_date

      t.timestamps
    end
  end
end
