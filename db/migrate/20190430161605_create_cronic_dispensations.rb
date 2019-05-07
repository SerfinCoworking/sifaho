class CreateCronicDispensations < ActiveRecord::Migration[5.2]
  def change
    create_table :cronic_dispensations do |t|
      t.references :prescription, index: true
      t.text :observation

      t.timestamps
    end
  end
end
