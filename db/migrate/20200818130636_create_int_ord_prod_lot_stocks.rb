class CreateIntOrdProdLotStocks < ActiveRecord::Migration[5.2]
  def change
    create_table :int_ord_prod_lot_stocks do |t|
      t.references :internal_order_product, index: true
      t.references :lot_stock, index: true
      t.integer :quantity

      t.timestamps
    end
  end
end
