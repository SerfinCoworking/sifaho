class CreateOutpatientPrescriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :outpatient_prescriptions do |t|
      t.references :professional, index: true
      t.references :patient, index: true
      t.references :provider_sector, index: true
      t.references :establishment, index: true
      t.string :remit_code
      t.text :observation

      t.datetime :date_prescribed
      t.date :expiry_date

      t.integer :status
      t.timestamps
    end
  end
end