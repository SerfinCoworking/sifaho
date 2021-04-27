class ChangeDatePrescribedDataTypeToOutpatientPrescription < ActiveRecord::Migration[5.2]
  def change
    change_column :outpatient_prescriptions, :date_prescribed, :date
  end
end
