class AddProviderObservationColumnToExternalOrderTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :external_order_templates, :provider_observation, :text
  end
end
