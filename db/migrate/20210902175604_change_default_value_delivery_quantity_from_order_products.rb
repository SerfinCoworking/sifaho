class ChangeDefaultValueDeliveryQuantityFromOrderProducts < ActiveRecord::Migration[5.2]
  def change
    change_column :external_order_products, :delivery_quantity, :integer, default: 0
    change_column :internal_order_products, :delivery_quantity, :integer, default: 0
  end
end
