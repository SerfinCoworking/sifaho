class AddParanoidToOfficeSupplies < ActiveRecord::Migration[5.1]
  def change
    add_column :office_supplies, :deleted_at, :datetime
    add_index :office_supplies, :deleted_at
  end
end
