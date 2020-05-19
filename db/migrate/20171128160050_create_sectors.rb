class CreateSectors < ActiveRecord::Migration[5.1]
  def change
    create_table :sectors do |t|
      t.string :name
      t.text :description
      t.integer :complexity_level
      t.integer :user_sectors_count, default: 0

      t.timestamps
    end
  end
end