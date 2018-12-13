class CreateUserSectors < ActiveRecord::Migration[5.1]
  def change
    create_table :user_sectors do |t|
      t.references :user, index: true
      t.references :sector, index: true

      t.timestamps
    end
  end
end