class AddEstablishmentToBedOrders < ActiveRecord::Migration[5.2]
  def change
    add_reference :bed_orders, :establishment, index: true
  end
end
