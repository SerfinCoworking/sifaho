namespace :batch do
  desc 'Update lot status'
  task update_lot_status: :environment do
    SupplyLot.all.each do |lot| 
      lot.update_status_without_validate!
    end

    SectorSupplyLot.all.each do |lot| 
      lot.update_status_without_validate!
    end
  end
end
