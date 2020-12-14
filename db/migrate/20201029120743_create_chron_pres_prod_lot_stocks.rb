class CreateChronPresProdLotStocks < ActiveRecord::Migration[5.2]
  def change
    create_table :chron_pres_prod_lot_stocks do |t|
      t.references :chronic_prescription_product, index: {name: :unique_chron_pres_prod_lot_stock_cpp}
      t.references :lot_stock, index: true
      
      t.integer :quantity

      t.timestamps
    end
  end
end
