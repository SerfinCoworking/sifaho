class AddStatusToInternalOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :internal_orders, :status, :integer, default: 0
  end
end
