class AddDeletedAtToPrescriptions < ActiveRecord::Migration[5.1]
  def change
    add_column :prescriptions, :deleted_at, :datetime
    add_index :prescriptions, :deleted_at
  end
end
