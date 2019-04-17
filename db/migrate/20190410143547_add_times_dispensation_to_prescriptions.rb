class AddTimesDispensationToPrescriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :prescriptions, :times_dispensation, :integer
  end
end
