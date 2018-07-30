class AddDeletedAtToSupplyLots < ActiveRecord::Migration[5.1]
  def change
    add_column :supply_lots, :deleted_at, :datetime
    add_index :supply_lots, :deleted_at
  end
end
