class AddUserStampsToInternalOrders < ActiveRecord::Migration[5.1]
  def change
    add_reference :internal_orders, :audited_by, index: true
    add_reference :internal_orders, :sent_by, index: true
    add_reference :internal_orders, :received_by, index: true    
    add_reference :internal_orders, :created_by, index: true
  end
end
