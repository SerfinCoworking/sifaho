class CreateInpatientMovements < ActiveRecord::Migration[5.2]
  def change
    create_table :inpatient_movements do |t|
      t.references :bed, index: true
      t.references :patient, index: true
      t.references :movement_type, index: true
      t.references :user, index: true
      t.text :observations

      t.timestamps
    end
  end
end
