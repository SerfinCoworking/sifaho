class AddDeletedAtToSupplies < ActiveRecord::Migration[5.1]
  def change
    add_column :supplies, :deleted_at, :datetime
    add_index :supplies, :deleted_at
  end
end
