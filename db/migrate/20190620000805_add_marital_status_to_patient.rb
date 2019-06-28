class AddMaritalStatusToPatient < ActiveRecord::Migration[5.2]
  def change
    add_column :patients, :marital_status, :integer, default: 1
  end
end
