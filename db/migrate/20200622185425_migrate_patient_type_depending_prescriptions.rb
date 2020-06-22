class MigratePatientTypeDependingPrescriptions < ActiveRecord::Migration[5.2]
  def change
    cronic_patient_type = PatientType.find_by_name("Crónico")
    Patient.find_each do |patient|
      if patient.prescriptions.where(order_type: 1).present?
        patient.patient_type = cronic_patient_type
        patient.save(validate: false)
      end
    end
  end
end
