class CreateVademecum < ActiveRecord::Migration[5.1]
  def change
    create_table :vademecums do |t|
      t.integer :code_number, :limit => 4
      t.integer :level_complexity
      t.boolean :indication
      t.string :specialty_enabled
      t.string :prescription_requirement
      t.boolean :emergency_car
      t.string :medication_name
      t.text :indications
    end
    add_reference :vademecums, :medication, foreign_key: true
  end
end
