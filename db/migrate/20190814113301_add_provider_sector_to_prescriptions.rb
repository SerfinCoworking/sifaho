class AddProviderSectorToPrescriptions < ActiveRecord::Migration[5.2]
  def change
    add_reference :prescriptions, :provider_sector, index: true
  end
end
