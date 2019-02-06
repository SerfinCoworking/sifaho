class MigrateAddPatientTypeToPatients < ActiveRecord::Migration[5.1]
  def change
    Patient.find_each do |patient|
      if patient.patient_type.present?
      else
        patient.patient_type = PatientType.find_by_id(1)
        patient.save(:validate => false)
      end
    end
  end
end
