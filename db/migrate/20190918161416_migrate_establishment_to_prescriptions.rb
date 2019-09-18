class MigrateEstablishmentToPrescriptions < ActiveRecord::Migration[5.2]
  def change
    Prescription.find_each do |pre|
      pre.establishment = pre.provider_sector.establishment
      pre.save!
    end
  end  
end
