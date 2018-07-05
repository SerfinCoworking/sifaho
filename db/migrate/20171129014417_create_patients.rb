class CreatePatients < ActiveRecord::Migration[5.1]
  def change
    create_table :patients do |t|
      t.string :first_name
      t.string :last_name
      t.integer :dni
      t.string :address
      t.string :email
      t.string :phone

      t.timestamps
    end
    add_reference :patients, :patient_type, foreign_key: true
  end
end
