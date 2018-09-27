class AddRemitCodeToOrderingSupply < ActiveRecord::Migration[5.1]
  def change
    add_column :ordering_supplies, :remit_code, :string
  end
end
