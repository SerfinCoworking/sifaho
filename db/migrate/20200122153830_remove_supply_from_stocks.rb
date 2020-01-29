class RemoveSupplyFromStocks < ActiveRecord::Migration[5.2]
  def change
    remove_column :stocks, :supply_id
  end
end
