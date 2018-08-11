class RemoveSectorFromSupplyLot < ActiveRecord::Migration[5.1]
  def change
    remove_column :supply_lots, :sector_id
  end
end
