class CreateChronicPrescriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :chronic_prescriptions do |t|
      t.references :professional, index: true
      t.references :patient, index: true
      t.references :provider_sector, index: true
      t.references :establishment, index: true

      t.string :remit_code
      t.text :diagnostic

      t.datetime :date_prescribed
      t.date :expiry_date

      t.integer :status
      t.timestamps
    end
  end
end
