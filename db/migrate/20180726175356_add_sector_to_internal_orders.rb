class AddSectorToInternalOrders < ActiveRecord::Migration[5.1]
  def change
    add_reference :internal_orders, :sector, foreign_key: true
  end
end
