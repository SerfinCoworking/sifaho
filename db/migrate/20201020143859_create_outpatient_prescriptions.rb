class CreateOutpatientPrescriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :outpatient_prescriptions do |t|
      t.references :professional, index: true
      t.references :patient, index: true
      t.string :remit_code
      t.text :observation

      t.date :date_received
      t.date :date_dispensed
      t.date :date_prescribed
      t.date :expiry_date

      t.integer :status
      t.timestamps
    end
  end
end
