class MigrateEstablishmentSector < ActiveRecord::Migration[5.1]
  Sector.find_each do |sector|
    sector.establishment_id = 65
    sector.save!
  end
end
