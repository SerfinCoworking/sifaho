class AddRemitCodeToInternalOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :internal_orders, :remit_code, :string, index: true
  end
end
