class MigrateCreatedByToPrescriptions < ActiveRecord::Migration[5.1]
  def change
    Prescription.all.each  do |pre|  
      unless pre.created_by_id.present?
        if pre.dispensed_by_id.present?
          pre.created_by_id = pre.dispensed_by_id
        else
          pre.created_by_id = 1
        end
        pre.save!
      end
    end
  end
end