class AddLatitudeAndLongitudeToEstablishments < ActiveRecord::Migration[5.2]
  def change
    add_column :establishments, :latitude, :string, default: '0'
    add_column :establishments, :longitude, :string, default: '0'
  end
end
