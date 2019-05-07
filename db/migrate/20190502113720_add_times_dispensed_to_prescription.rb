class AddTimesDispensedToPrescription < ActiveRecord::Migration[5.2]
  def change
    add_column :prescriptions, :times_dispensed, :integer, default: 0
  end
end
