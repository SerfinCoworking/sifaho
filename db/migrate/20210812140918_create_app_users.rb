class CreateAppUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :app_users do |t|
      t.string :username
      t.string :password_digest

      t.timestamps
    end
  end
end
