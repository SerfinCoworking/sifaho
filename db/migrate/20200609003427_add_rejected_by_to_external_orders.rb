class AddRejectedByToExternalOrders < ActiveRecord::Migration[5.2]
  def change
    add_reference :external_orders, :rejected_by, index: true
  end
end
