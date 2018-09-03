class AddSupplyToQuantityOrdSupplyLot < ActiveRecord::Migration[5.1]
  def change
    add_reference :quantity_ord_supply_lots, :supply, foreign_key: true
  end
end
