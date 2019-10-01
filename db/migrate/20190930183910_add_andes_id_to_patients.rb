class AddAndesIdToPatients < ActiveRecord::Migration[5.2]
  def change
    add_column :patients, :andes_id, :string, index: true
  end
end
