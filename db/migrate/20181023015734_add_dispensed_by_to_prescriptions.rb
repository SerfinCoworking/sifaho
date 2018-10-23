class AddDispensedByToPrescriptions < ActiveRecord::Migration[5.1]
  def change
    add_reference :prescriptions, :created_by, index: true
    add_reference :prescriptions, :audited_by, index: true
    add_reference :prescriptions, :dispensed_by, index: true

    add_column :prescriptions, :audited_at, :datetime
    add_column :prescriptions, :dispensed_at, :datetime
  end
end
