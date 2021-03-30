class RemoveIndexFromPatientPhones < ActiveRecord::Migration[5.2]
  def change
    remove_index :patient_phones, name: "index_patient_phones_on_number_and_patient_id"    
  end
end
