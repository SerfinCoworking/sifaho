class CreatePurchaseProdLotStocks < ActiveRecord::Migration[5.2]
  def change
    create_table :purchase_prod_lot_stocks do |t|
      t.references :purchase_product, index: true
      t.references :lot_stock, index: true
      t.references :laboratory, index: true
      
      t.string :lot_code
      t.date :expiry_date
      t.integer :position # campo para ordenar
      t.integer :quantity
      t.integer :presentation
      t.timestamps
    end
  end
end
