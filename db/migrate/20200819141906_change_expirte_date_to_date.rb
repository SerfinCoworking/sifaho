class ChangeExpirteDateToDate < ActiveRecord::Migration[5.2]
  def change
    change_column :supply_lots, :expiry_date, :date
    change_column :quantity_ord_supply_lots, :expiry_date, :date
  end
end
