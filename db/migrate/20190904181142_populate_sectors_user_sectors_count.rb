class PopulateSectorsUserSectorsCount < ActiveRecord::Migration[5.2]
  def change
    Sector.find_each do |sector|
      Sector.reset_counters(sector.id, :user_sectors)
    end
  end
end
