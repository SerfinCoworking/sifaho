class RemoveColumnsOnInternalOrder < ActiveRecord::Migration[5.2]
  def change
    remove_column :internal_orders, :created_by_id
    remove_column :internal_orders, :audited_by_id
    remove_column :internal_orders, :sent_by_id
    remove_column :internal_orders, :received_by_id
    remove_column :internal_orders, :sent_request_by_id
    remove_column :internal_orders, :rejected_by_id
  end
end
