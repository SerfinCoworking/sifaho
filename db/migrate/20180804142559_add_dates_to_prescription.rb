class AddDatesToPrescription < ActiveRecord::Migration[5.1]
  def change
    add_column :prescriptions, :prescribed_date, :datetime
    add_column :prescriptions, :expiry_date, :datetime
  end
end
