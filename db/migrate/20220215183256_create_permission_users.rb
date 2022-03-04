class CreatePermissionUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :permission_users do |t|
      t.references :user, index: true, unique: true
      t.references :sector, index: true, unique: true
      t.references :permission, index: true, unique: true
      t.timestamps
    end
  end
end
