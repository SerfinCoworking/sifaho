class AddDateDispensedToOutpatientPrescriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :outpatient_prescriptions, :date_dispensed, :datetime

    # Buscamos todas las prescripciones ambulatorias del bk con estado "dispensada" y le cargamos el valor de "date_dispensed"
    @old_prescriptions = Prescription.ambulatoria.dispensada.where.not(dispensed_at: nil)
    @old_prescriptions.each do |outpatient_prescription|
      outpatient_pres = OutpatientPrescription.where(id: outpatient_prescription.id).first
      if outpatient_pres.present?
        outpatient_pres.date_dispensed = outpatient_prescription.dispensed_at
        outpatient_pres.save(validate: false)

        puts "Old Ambulatoria: #{outpatient_pres.id} - Dispensada: #{outpatient_pres.date_dispensed.strftime("%d/%m/%Y")}".colorize(:green)
      end
    end
    
    # Buscamos todas las prescripciones ambulatorias post migracion con estado "dispensada" y le cargamos el valor de "updated_at"
    @new_prescriptions = OutpatientPrescription.dispensada.where.not(id: @old_prescriptions.pluck(:id))
    @new_prescriptions.each do |outpatient_prescription|
      outpatient_prescription.date_dispensed = outpatient_prescription.updated_at
      outpatient_prescription.save(validate: false)

      puts "New Ambulatoria: #{outpatient_prescription.id} - Dispensada: #{outpatient_prescription.date_dispensed.strftime("%d/%m/%Y")}".colorize(:green)
    end

    puts "Total OLD prescripciones dispensadas actualizadas:".colorize( :background => :green) + " #{@old_prescriptions.count}".colorize(:green)
    puts "Total NEW prescripciones dispensadas actualizadas:".colorize( :background => :green) + " #{@new_prescriptions.count}".colorize(:green)
  end
end
