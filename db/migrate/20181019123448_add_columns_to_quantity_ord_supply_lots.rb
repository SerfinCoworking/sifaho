class AddColumnsToQuantityOrdSupplyLots < ActiveRecord::Migration[5.1]
  def change
    add_column :quantity_ord_supply_lots, :treatment_duration, :integer
    add_column :quantity_ord_supply_lots, :daily_dose, :integer
  end
end
