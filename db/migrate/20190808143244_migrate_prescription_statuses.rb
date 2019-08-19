class MigratePrescriptionStatuses < ActiveRecord::Migration[5.2]
  def change
    Prescription.find_each do |pre|
      if pre.cronica?
        unless pre.vencida?
          if pre.times_dispensed == pre.times_dispensation
            pre.dispensada!
          elsif pre.times_dispensed == 0 
            pre.pendiente!
          elsif pre.times_dispensed > 0
            pre.dispensada_parcial!; 
          end
        end
      end
    end
  end
end
