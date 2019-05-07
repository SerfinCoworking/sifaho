class AddDispensedAtToQuantityOrdSupplyLot < ActiveRecord::Migration[5.2]
  def change
    add_column :quantity_ord_supply_lots, :dispensed_at, :datetime
  end
end
