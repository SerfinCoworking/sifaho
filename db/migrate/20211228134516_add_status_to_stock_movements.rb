class AddStatusToStockMovements < ActiveRecord::Migration[5.2]
  def up
    add_column :stock_movements, :status, :text
  end
  
  def down
    remove_column :stock_movements, :status
  end
end
