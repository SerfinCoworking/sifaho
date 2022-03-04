namespace :batch do
  desc 'Update lot status'
  task update_lot_status: :environment do
    Rails.logger.info 'Start update lot status. Vigentes: '+Lot.vigente.count.to_s+' Por vencer: '+Lot.por_vencer.count.to_s+' Vencido: '+Lot.vencido.count.to_s
    Lot.without_status(2).find_each do |lot| 
      lot.update_status
      lot.save(:validate => false)
      #lot.save!
    end
    Rails.logger.info 'Finished update lot status. Vigentes: '+Lot.vigente.count.to_s+' Por vencer: '+Lot.por_vencer.count.to_s+' Vencido: '+Lot.vencido.count.to_s
  end

  desc 'Update outpatient prescription status'
  task update_outpatient_prescription_status: :environment do
    Rails.logger.info 'Start update outpatient prescription status. Pendientes: '+OutpatientPrescription.pendiente.count.to_s+' Dispensadas: '+OutpatientPrescription.dispensada.count.to_s+' Vencidas: '+OutpatientPrescription.vencida.count.to_s
    OutpatientPrescription.pendiente.find_each do |prescription| 
      prescription.update_status
      prescription.save(validate: false)
    end
    Rails.logger.info 'Finished update outpatient prescription status. Pendientes: '+OutpatientPrescription.pendiente.count.to_s+' Dispensadas: '+OutpatientPrescription.dispensada.count.to_s+' Vencidas: '+OutpatientPrescription.vencida.count.to_s
  end

  desc 'Update chronic prescription status'
  task update_chronic_prescription_status: :environment do
    Rails.logger.info 'Start update chronic prescription status. Dispensadas parcialmente: '+ChronicPrescription.dispensada_parcial.count.to_s+' Dispensadas: '+ChronicPrescription.dispensada.count.to_s+' Vencidas: '+ChronicPrescription.vencida.count.to_s
    ChronicPrescription.for_statuses(['dispensada_parcial', 'pendiente']).find_each do |prescription|
      prescription.update_status
      prescription.save(validate: false)
    end
    Rails.logger.info 'Finished update outpatient prescription status. Dispensadas parcialmente: '+ChronicPrescription.dispensada_parcial.count.to_s+' Dispensadas: '+ChronicPrescription.dispensada.count.to_s+' Vencidas: '+ChronicPrescription.vencida.count.to_s
  end

  desc 'Update inpatient prescription status'
  task update_inpatient_prescription_status: :environment do
    Rails.logger.info 'Starting update inpatient prescription status...'
    Rails.logger.info "Pendientes: #{InpatientPrescription.pending.count}"
    Rails.logger.info "Parcialmente dispensadas: #{InpatientPrescription.parcialmente_dispensada.count}"
    Rails.logger.info "Dispensadas: #{InpatientPrescription.dispensada.count}"
    Rails.logger.info "Terminadas: #{InpatientPrescription.finished.count}"

    InpatientPrescription.for_statuses(['dispensada_parcial', 'pending']).find_each do |prescription|
      prescription.update_status
    end
    Rails.logger.info 'Finished update outpatient prescription status.'
  end
end
