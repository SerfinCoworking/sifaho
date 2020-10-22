class AddIndexToInternalOrderProducts < ActiveRecord::Migration[5.2]
  def change
    add_index :internal_order_products, [:internal_order_id, :product_id], :unique => true, name: "unique_product_on_internal_order_products"
  end
end
