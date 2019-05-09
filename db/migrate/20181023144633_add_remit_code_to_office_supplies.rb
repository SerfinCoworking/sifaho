class AddRemitCodeToOfficeSupplies < ActiveRecord::Migration[5.1]
  def change
    add_column :office_supplies, :remit_code, :string
    add_index :office_supplies, :remit_code, unique: true
  end
end
