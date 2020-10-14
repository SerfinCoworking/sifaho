class RemoveDeletedAtFromInternalOrders < ActiveRecord::Migration[5.2]
  def change
    remove_column :internal_orders, :deleted_at, :datetime
  end
end
