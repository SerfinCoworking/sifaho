class AddCurrentSectorToOptionSectors < ActiveRecord::Migration[5.1]
  def change
    User.find_each do |user|
      user.sectors << Sector.find(user.sector_id)
      user.save
    end
  end
end
