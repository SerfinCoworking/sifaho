class AddSectorToUser < ActiveRecord::Migration[5.1]
  def change
    add_reference :users, :sector, foreign_key: true
  end
end
