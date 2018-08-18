class MigrateLaboratoryToSupplyLots < ActiveRecord::Migration[5.1]
  SupplyLot.with_deleted.find_each do |sl|
    sl.laboratory_id = 4
    sl.save!
  end
end
