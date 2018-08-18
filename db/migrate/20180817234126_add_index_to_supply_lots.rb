class AddIndexToSupplyLots < ActiveRecord::Migration[5.1]
  def change
    add_index :supply_lots, [:lot_code, :laboratory_id], unique: true
  end
end
