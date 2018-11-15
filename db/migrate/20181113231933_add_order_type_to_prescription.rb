class AddOrderTypeToPrescription < ActiveRecord::Migration[5.1]
  def up
    add_column :prescriptions, :order_type, :integer, default: 0
  end
  def down
    remove_column :prescriptions, :order_type
  end 
end
