class AddBedroomToBedOrders < ActiveRecord::Migration[5.2]
  def change
    add_reference :bed_orders, :bedroom, index: true
  end
end
