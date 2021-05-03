namespace :batch do
  desc 'Update lot status'
  task update_lot_status: :environment do
    Rails.logger.info 'Start update lot status. Vigentes: '+Lot.vigente.count.to_s+' Por vencer: '+Lot.por_vencer.count.to_s+' Vencido: '+Lot.vencido.count.to_s
    Lot.without_status(2).find_each do |lot| 
      lot.update_status
      lot.save!
    end
    Rails.logger.info 'Finished update lot status. Vigentes: '+Lot.vigente.count.to_s+' Por vencer: '+Lot.por_vencer.count.to_s+' Vencido: '+Lot.vencido.count.to_s
  end
end
