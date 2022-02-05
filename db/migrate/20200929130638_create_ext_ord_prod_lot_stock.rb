class CreateExtOrdProdLotStock < ActiveRecord::Migration[5.2]
  def change
    create_table :ext_ord_prod_lot_stocks do |t|
      t.references :external_order_product, index: true
      t.references :lot_stock, index: true
      t.integer :quantity
      t.integer :reserved_quantity, default: 0

      t.timestamps
    end
  end
end