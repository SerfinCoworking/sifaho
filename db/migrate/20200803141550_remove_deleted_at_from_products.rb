class RemoveDeletedAtFromProducts < ActiveRecord::Migration[5.2]
  def change
    remove_column :products, :deleted_at, :datetime
  end
end
