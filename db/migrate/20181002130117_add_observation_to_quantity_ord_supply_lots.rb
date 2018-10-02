class AddObservationToQuantityOrdSupplyLots < ActiveRecord::Migration[5.1]
  def change
    add_column :quantity_ord_supply_lots, :observation, :text
  end
end
