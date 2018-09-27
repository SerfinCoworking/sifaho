class AddTypeToOrderingSupply < ActiveRecord::Migration[5.1]
  def change
    add_column :ordering_supplies, :order_type, :integer, default: 0
  end
end
