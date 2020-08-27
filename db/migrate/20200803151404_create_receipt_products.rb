class CreateReceiptProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :receipt_products do |t|
      t.references :receipt, index: true
      t.references :lot_stock, index: true
      t.references :product, index: true      
      t.references :laboratory, index: true
      t.integer :quantity
      t.string :lot_code
      t.datetime :expiry_date

      t.timestamps
    end
  end
end
