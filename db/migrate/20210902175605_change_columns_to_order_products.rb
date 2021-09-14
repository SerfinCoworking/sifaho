class ChangeColumnsToOrderProducts < ActiveRecord::Migration[5.2]
  def up
    rename_column :ext_ord_prod_lot_stocks, :external_order_product_id, :order_product_id
    rename_column :int_ord_prod_lot_stocks, :internal_order_product_id, :order_product_id

    change_column :ext_ord_prod_lot_stocks, :order_product_id, :bigint, foreign_key: { to_table: :external_order_products }
    change_column :int_ord_prod_lot_stocks, :order_product_id, :bigint, foreign_key: { to_table: :internal_order_products }
  end

  def down
    rename_column :ext_ord_prod_lot_stocks, :order_id, :external_order_product_id
    rename_column :int_ord_prod_lot_stocks, :order_id, :internal_order_product_id
  end
end
