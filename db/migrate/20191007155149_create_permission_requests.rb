class CreatePermissionRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :permission_requests do |t|
      t.references :user, foreign_key: true
      t.integer :status, default: 0
      t.string :establishment
      t.string :sector
      t.string :role
      t.text :observation

      t.timestamps
    end
  end
end
