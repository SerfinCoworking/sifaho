class SetDefaultFieldsToPatients < ActiveRecord::Migration[5.1]
  def change
    change_column :patients, :patient_type_id, :bigint, default: 1
  end
end
