class AddArchivedQuantityAndPresentationOnLotStocks < ActiveRecord::Migration[5.2]
  def change
    add_column :lot_stocks, :archived_quantity, :integer, default: 0
    add_column :lot_stocks, :presentation, :integer
  end
end
