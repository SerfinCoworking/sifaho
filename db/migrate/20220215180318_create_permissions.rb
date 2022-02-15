class CreatePermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :permissions do |t|
      t.string :name
      t.references :permission_module, index: true
      t.timestamps
    end
  end
end
