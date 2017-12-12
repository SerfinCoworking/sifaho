class CreatePrescriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :prescriptions do |t|
      t.text :observation
      t.datetime :date_received
      t.datetime :date_processed
      t.integer :patient_id
      t.integer :prescription_status_id

      t.timestamps
    end
    add_reference :prescriptions, :professional, foreign_key: true
    add_reference :prescriptions, :patient, foreign_key: true
  end
end
