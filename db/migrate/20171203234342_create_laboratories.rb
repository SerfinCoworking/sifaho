class CreateLaboratories < ActiveRecord::Migration[5.1]
  def change
    create_table :laboratories do |t|
      t.string :name
      t.string :address

      t.timestamps
    end
  end
end
