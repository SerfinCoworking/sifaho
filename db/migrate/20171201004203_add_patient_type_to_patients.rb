class AddPatientTypeToPatients < ActiveRecord::Migration[5.1]
  def change
    add_reference :patients, :patient_type, foreign_key: true
  end
end
