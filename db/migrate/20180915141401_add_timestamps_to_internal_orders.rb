class AddTimestampsToInternalOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :internal_orders, :requested_date, :datetime
    add_column :internal_orders, :sent_date, :datetime
  end
end
