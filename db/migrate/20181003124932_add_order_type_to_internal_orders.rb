class AddOrderTypeToInternalOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :internal_orders, :order_type, :integer, default: 0
  end
end
