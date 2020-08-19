class ChangesExpiryDateFromSupplyLots < ActiveRecord::Migration[5.2]
  def change
    change_column :receipt_products, :expiry_date, :date
  end

end
