class RemoveAttributesFromPatient < ActiveRecord::Migration[5.2]
  def change
    remove_column :patients, :patient_type_id
    remove_column :patients, :is_chronic
    remove_column :patients, :is_urban
    remove_column :patients, :phone
    remove_column :patients, :cell_phone
  end
end
