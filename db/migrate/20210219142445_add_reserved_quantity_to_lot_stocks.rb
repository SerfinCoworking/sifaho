class AddReservedQuantityToLotStocks < ActiveRecord::Migration[5.2]
  def change
    add_column :lot_stocks, :reserved_quantity, :integer, default: 0 
  end
end
