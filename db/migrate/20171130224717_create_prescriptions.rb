class CreatePrescriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :prescriptions do |t|
      t.string :observation
      t.datetime :date_received
      t.datetime :date_processed
      t.integer :id_professional
      t.integer :id_patient
      t.integer :id_prescription_status

      t.timestamps
    end
  end
end
