class ChangeDefaultValueToQuantityFromStocks < ActiveRecord::Migration[5.2]
  def change
    change_column :stocks, :quantity, :integer, default: 0
  end
end
