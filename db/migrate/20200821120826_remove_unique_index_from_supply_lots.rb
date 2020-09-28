class RemoveUniqueIndexFromSupplyLots < ActiveRecord::Migration[5.2]
  def change
    remove_index :supply_lots, [:supply_id, :lot_code, :laboratory_id]
    add_index :supply_lots, [:supply_id, :lot_code, :laboratory_id], :name => 'supply_lot_laboratory_index'
  end
end
