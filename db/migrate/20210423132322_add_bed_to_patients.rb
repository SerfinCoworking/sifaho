class AddBedToPatients < ActiveRecord::Migration[5.2]
  def change
    add_reference :patients, :bed, index: true
  end
end
