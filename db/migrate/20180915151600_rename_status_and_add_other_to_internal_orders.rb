class RenameStatusAndAddOtherToInternalOrders < ActiveRecord::Migration[5.1]
  def change
    rename_column :internal_orders, :status, :provider_status
    add_column :internal_orders, :applicant_status, :integer, default: 0
  end
end
