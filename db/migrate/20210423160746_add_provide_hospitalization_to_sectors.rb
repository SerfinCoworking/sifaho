class AddProvideHospitalizationToSectors < ActiveRecord::Migration[5.2]
  def change
    add_column :sectors, :provide_hospitalization, :boolean, default: false
  end
end
