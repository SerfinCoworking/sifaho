class SetUniqueLotCodeToSupplyLot < ActiveRecord::Migration[5.1]
  def change
    add_index :supply_lots, :lot_code, unique: true
  end
end
