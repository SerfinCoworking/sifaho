class AddDeletedAtToLots < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :deleted_at, :datetime
    add_index :lots, :deleted_at
  end
end
