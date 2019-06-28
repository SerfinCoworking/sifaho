class CreatePatientPhones < ActiveRecord::Migration[5.2]
  def change
    create_table :patient_phones do |t|
      t.integer :phone_type, default: 1
      t.string :number
      t.references :patient, foreign_key: true

      t.timestamps
    end
  end
end
