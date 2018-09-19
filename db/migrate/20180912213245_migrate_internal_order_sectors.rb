class MigrateInternalOrderSectors < ActiveRecord::Migration[5.1]
  InternalOrder.find_each do |io|
    prov_user = User.find(io.provider_id)
    appl_user = User.find(io.applicant_id)
    io.provider_sector_id = prov_user.sector_id
    io.applicant_sector_id = appl_user.sector_id
    io.requested_date = io.created_at
    io.created_by_id = prov_user.id
    io.save!
  end
end
