class CreatePrescriptionMedications < ActiveRecord::Migration[5.1]
  def change
    create_table :prescription_medications do |t|
      t.integer :prescription_id
      t.integer :medication_id
      t.integer :quantity

      t.timestamps
    end

    add_index :prescription_medications, [:prescription_id, :medication_id], name: 'index_prescription_medication'
  end
end
