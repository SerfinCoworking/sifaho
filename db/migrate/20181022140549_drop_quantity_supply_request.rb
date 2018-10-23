class DropQuantitySupplyRequest < ActiveRecord::Migration[5.1]
  def change
    drop_table :quantity_supply_requests
  end
end
