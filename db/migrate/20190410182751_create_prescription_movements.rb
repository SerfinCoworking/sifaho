class CreatePrescriptionMovements < ActiveRecord::Migration[5.2]
  def change
    create_table :prescription_movements do |t|
      t.references :user, index: true
      t.references :prescription, index: true
      t.references :sector, index: true
      t.string :action

      t.timestamps
    end
  end
end
