class ChangesExpiryDateFromSupplyLots < ActiveRecord::Migration[5.2]
  def change
    change_column :supply_lots, :expiry_date, :date
    change_column :receipt_products, :expiry_date, :date
  end

end
