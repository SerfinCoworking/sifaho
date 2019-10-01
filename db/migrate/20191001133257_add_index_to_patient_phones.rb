class AddIndexToPatientPhones < ActiveRecord::Migration[5.2]
  def change
    add_index :patient_phones, [:number, :patient_id], unique: true
  end
end
