class AddRemitCodeToPrescriptions < ActiveRecord::Migration[5.1]
  def change
    add_column :prescriptions, :remit_code, :string
  end
end
