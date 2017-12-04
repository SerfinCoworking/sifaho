class CreateVademecum < ActiveRecord::Migration[5.1]
  def change
    create_table :vademecums do |t|
      t.integer :complexity_level
      t.boolean :indication
      t.string :specialty_enabled
      t.string :prescription_requirements
      t.boolean :emergency_car
      t.string :medications
      t.text :indications
    end
  end
end
