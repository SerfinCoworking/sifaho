class CreateOutpatientPrescriptionMovements < ActiveRecord::Migration[5.2]
  def change
    create_table :outpatient_prescription_movements do |t|
      t.references :user, index: true
      t.references :outpatient_prescription, index: {name: :unique_out_pres_on_out_pres_movements}
      t.references :sector, index: true
      t.string :action

      t.timestamps
    end
  end
end
