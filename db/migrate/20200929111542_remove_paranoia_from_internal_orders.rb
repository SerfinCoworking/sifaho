class RemoveParanoiaFromInternalOrders < ActiveRecord::Migration[5.2]
  def change
    InternalOrder.only_deleted.find_each do |order|
      order.really_destroy!
    end
  end
end
