class ChangeIndexSupplyLot < ActiveRecord::Migration[5.1]
  def change
    add_index :supply_lots, [:supply_id, :lot_code, :laboratory_id], unique: true
    remove_index :supply_lots, [:lot_code, :laboratory_id]
  end
end
