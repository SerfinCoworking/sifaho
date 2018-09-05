class CreateSectors < ActiveRecord::Migration[5.1]
  def change
    create_table :sectors do |t|
      t.string :name
      t.text :description
      t.integer :complexity_level

      t.timestamps
    end
  end
end
