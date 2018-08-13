class AddDeletedAtToInternalOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :internal_orders, :deleted_at, :datetime
    add_index :internal_orders, :deleted_at
  end
end
