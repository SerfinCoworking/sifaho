class RemoveColumnDeletedAtFromExternalOrder < ActiveRecord::Migration[5.2]
  def change
    remove_column :external_orders, :deleted_at, :datetime
  end
end
