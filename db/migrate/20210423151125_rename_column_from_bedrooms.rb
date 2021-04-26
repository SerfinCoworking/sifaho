class RenameColumnFromBedrooms < ActiveRecord::Migration[5.2]
  def change
    rename_column :bedrooms, :sector_id, :location_sector_id
  end
end
