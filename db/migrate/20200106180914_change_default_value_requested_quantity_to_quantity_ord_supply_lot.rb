class ChangeDefaultValueRequestedQuantityToQuantityOrdSupplyLot < ActiveRecord::Migration[5.2]
  def change
    change_column :quantity_ord_supply_lots, :requested_quantity, :integer, default: 0
  end
end
