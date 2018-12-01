class AddSentRequestByToOrderingSupplies < ActiveRecord::Migration[5.1]
  def change
    add_reference :ordering_supplies, :sent_request_by, index: true
  end
end
