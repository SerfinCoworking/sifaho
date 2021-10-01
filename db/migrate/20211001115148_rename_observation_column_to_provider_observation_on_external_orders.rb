class RenameObservationColumnToProviderObservationOnExternalOrders < ActiveRecord::Migration[5.2]
  def up
    rename_column :external_orders, :observation, :provider_observation
  end

  def down
    rename_column :external_orders, :provider_observation, :observation
  end
end
