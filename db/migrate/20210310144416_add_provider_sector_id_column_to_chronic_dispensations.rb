class AddProviderSectorIdColumnToChronicDispensations < ActiveRecord::Migration[5.2]
  def change
    add_reference :chronic_dispensations, :provider_sector, index: true
  end
end
