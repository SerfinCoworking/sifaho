class CreateOutPresProdLotStocks < ActiveRecord::Migration[5.2]
  def change
    create_table :out_pres_prod_lot_stocks do |t|
      t.references :outpatient_prescription_product, index: {name: :unique_out_pres_prod_lot_stocks_on_out_pres_prod}
      t.references :lot_stock, index: true
      t.integer :quantity
      t.timestamps
    end
  end
end
