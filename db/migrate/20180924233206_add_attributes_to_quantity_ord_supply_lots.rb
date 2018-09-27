class AddAttributesToQuantityOrdSupplyLots < ActiveRecord::Migration[5.1]
  def change
    add_column :quantity_ord_supply_lots, :expiry_date, :datetime
    add_column :quantity_ord_supply_lots, :lot_code, :string
    add_reference :quantity_ord_supply_lots, :laboratory, foreign_key: true
  end
end
