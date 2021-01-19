class DropExternalOrders < ActiveRecord::Migration[5.2]
  def change
    ExternalOrder.find_each do |order|
      order.destroy!
    end
  end
end
