class CreatePatients < ActiveRecord::Migration[5.1]
  def change
    create_table :patients do |t|
      t.string :first_name, :limit => 100
      t.string :last_name, :limit => 100
      t.integer :dni
      t.integer :sex, default: 1
      t.datetime :birthdate
      t.boolean :is_chronic
      t.boolean :is_urban
      t.string :phone, :limit => 20
      t.string :cell_phone, :limit => 20
      t.string :email, :limit => 50

      t.timestamps
    end
    add_reference :patients, :patient_type, foreign_key: true
  end
end
