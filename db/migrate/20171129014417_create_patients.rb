class CreatePatients < ActiveRecord::Migration[5.1]
  def change
    create_table :patients do |t|
      t.string :andes_id, index: true
      t.string :first_name, :limit => 100
      t.string :last_name, :limit => 100
      t.integer :status, default: 0
      t.integer :dni
      t.integer :sex, default: 1
      t.integer :marital_status, default: 1
      t.datetime :birthdate
      t.string :email, :limit => 50
      t.string :cuil

      t.timestamps
    end
  end
end