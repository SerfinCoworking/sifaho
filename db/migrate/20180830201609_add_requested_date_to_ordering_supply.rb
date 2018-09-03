class AddRequestedDateToOrderingSupply < ActiveRecord::Migration[5.1]
  def change
    add_column :ordering_supplies, :requested_date, :datetime
  end
end
