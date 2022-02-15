class CreatePermissionModules < ActiveRecord::Migration[5.2]
  def change
    create_table :permission_modules do |t|
      t.string :name
      t.timestamps
    end
  end
end
