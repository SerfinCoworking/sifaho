class AddUserSectorsCountToSector < ActiveRecord::Migration[5.2]
  def change
    add_column :sectors, :user_sectors_count, :integer, default: 0
  end
end
