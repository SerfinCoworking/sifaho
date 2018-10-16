class ChangeObservationToQuantityOrdSupplyLots < ActiveRecord::Migration[5.1]
  def change
    rename_column :quantity_ord_supply_lots, :observation, :applicant_observation
    add_column :quantity_ord_supply_lots, :provider_observation, :text 
  end
end
