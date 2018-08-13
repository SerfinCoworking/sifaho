class AddDeletedAtToOrderingSupplies < ActiveRecord::Migration[5.1]
  def change
    add_column :ordering_supplies, :deleted_at, :datetime
    add_index :ordering_supplies, :deleted_at
  end
end
