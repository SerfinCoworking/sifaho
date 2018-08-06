class AddLotCodeToSupplyLot < ActiveRecord::Migration[5.1]
  def change
    add_column :supply_lots, :lot_code, :string, :limit => 20
  end
end
