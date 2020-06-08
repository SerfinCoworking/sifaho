class AddRejectedByToInternalOrders < ActiveRecord::Migration[5.2]
  def change
    add_reference :internal_orders, :rejected_by, index: true
  end
end
