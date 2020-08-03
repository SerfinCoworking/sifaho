class CreateReceiptProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :receipt_products do |t|
      t.references :supply, index: true
      t.references :supply_lot, index: true
      t.integer :quantity
      t.string :lot_code
      t.string :lobarotory_name
      t.datetime :expiry_date

      t.timestamps
    end
  end
end
