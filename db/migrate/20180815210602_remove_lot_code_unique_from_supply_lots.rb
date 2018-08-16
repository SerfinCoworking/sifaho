class RemoveLotCodeUniqueFromSupplyLots < ActiveRecord::Migration[5.1]
  def change
    remove_index :supply_lots, :lot_code
  end
end
