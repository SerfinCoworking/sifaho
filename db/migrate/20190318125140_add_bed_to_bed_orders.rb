class AddBedToBedOrders < ActiveRecord::Migration[5.2]
  def change
    add_reference :bed_orders, :bed, index: true
  end
end
