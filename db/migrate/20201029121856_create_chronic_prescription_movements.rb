class CreateChronicPrescriptionMovements < ActiveRecord::Migration[5.2]
  def change
    create_table :chronic_prescription_movements do |t|
      t.references :chronic_prescription, index: {name: :unique_chron_pres_on_out_pres_movements}
      t.references :user, index: true
      t.references :sector, index: true
      t.string :action

      t.timestamps
    end
  end
end
