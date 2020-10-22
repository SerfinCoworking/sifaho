class ChangesExpiryDateFromLots < ActiveRecord::Migration[5.2]
  def change
    change_column :lots, :expiry_date, :date
  end
end
