class RenameColumnNameFromOrderProductsTables < ActiveRecord::Migration[5.2]
  def up
    rename_column :external_order_products, :external_order_id, :order_id
    rename_column :internal_order_products, :internal_order_id, :order_id

    change_column :external_order_products, :order_id, :bigint, foreign_key: { to_table: :external_orders }
    change_column :internal_order_products, :order_id, :bigint, foreign_key: { to_table: :internal_orders }
  end

  def down
    rename_column :external_order_products, :order_id, :external_order_id
    rename_column :internal_order_products, :order_id, :internal_order_id
  end
end
