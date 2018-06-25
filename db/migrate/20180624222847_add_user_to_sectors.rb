class AddUserToSectors < ActiveRecord::Migration[5.1]
  def change
    add_reference :sectors, :user, foreign_key: true
  end
end
