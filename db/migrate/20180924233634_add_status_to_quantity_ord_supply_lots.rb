class AddStatusToQuantityOrdSupplyLots < ActiveRecord::Migration[5.1]
  def change
    add_column :quantity_ord_supply_lots, :status, :integer, default: 0
  end
end
