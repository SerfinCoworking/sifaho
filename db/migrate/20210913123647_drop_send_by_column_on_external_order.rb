class DropSendByColumnOnExternalOrder < ActiveRecord::Migration[5.2]
  def change
    remove_column :external_orders, :sent_by_id
  end
end
