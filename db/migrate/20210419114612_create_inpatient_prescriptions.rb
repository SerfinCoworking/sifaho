class CreateInpatientPrescriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :inpatient_prescriptions do |t|
      t.references :patient, index: true
      t.references :professional, index: true
      t.references :bed, index: true
      t.references :prescribed_by
      t.string :remit_code
      t.text :observation
      t.integer :status, default: 0
      t.date :date_prescribed

      t.timestamps
    end
  end
end
