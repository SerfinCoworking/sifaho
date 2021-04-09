class CreateDepartments < ActiveRecord::Migration[5.2]
  def change
    create_table :departments do |t|
      t.string :name
      t.references :state, index: true
      t.references :sanitary_zone, index: true

      t.timestamps
    end
  end
end
