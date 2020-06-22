class AddPatientTypeToPatients < ActiveRecord::Migration[5.2]
  def change
    add_reference :patients, :patient_type, index: true, default: 1
  end
end
