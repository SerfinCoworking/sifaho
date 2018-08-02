class AddStatusToPrescription < ActiveRecord::Migration[5.1]
  def change
    add_column :prescriptions, :status, :integer, default: 0
    remove_column :prescriptions, :prescription_status_id
  end
end
