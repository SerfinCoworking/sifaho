class CreateChronicDispensations < ActiveRecord::Migration[5.2]
  def change
    create_table :chronic_dispensations do |t|
      t.references :chronic_prescription, index: true
      t.text :observation
      t.integer :status
      t.timestamps
    end
  end
end
