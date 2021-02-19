class AddTotalAndReservedQuantityToStocks < ActiveRecord::Migration[5.2]
  def change
    add_column :stocks, :total_quantity, :integer, default: 0
    add_column :stocks, :reserved_quantity, :integer, default: 0
  end
end
