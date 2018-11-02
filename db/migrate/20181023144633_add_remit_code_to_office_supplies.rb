class AddRemitCodeToOfficeSupplies < ActiveRecord::Migration[5.1]
  def change
    add_column :office_supplies, :remit_code, :string
  end
end
