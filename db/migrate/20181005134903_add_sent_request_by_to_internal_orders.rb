class AddSentRequestByToInternalOrders < ActiveRecord::Migration[5.1]
  def change
    add_reference :internal_orders, :sent_request_by, index: true
  end
end
