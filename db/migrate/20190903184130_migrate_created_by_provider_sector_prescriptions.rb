class MigrateCreatedByProviderSectorPrescriptions < ActiveRecord::Migration[5.2]
  def change
    Prescription.find_each do |pre|
      pre.provider_sector = pre.created_by.sector
      pre.save!
    end
  end
end
