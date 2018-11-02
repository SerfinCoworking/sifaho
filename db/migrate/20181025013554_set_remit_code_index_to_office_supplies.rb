class SetRemitCodeIndexToOfficeSupplies < ActiveRecord::Migration[5.1]
  def change
    add_index :office_supplies, :remit_code, unique: true
  end
end
