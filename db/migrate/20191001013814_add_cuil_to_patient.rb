class AddCuilToPatient < ActiveRecord::Migration[5.2]
  def change
    add_column :patients, :cuil, :string
  end
end
