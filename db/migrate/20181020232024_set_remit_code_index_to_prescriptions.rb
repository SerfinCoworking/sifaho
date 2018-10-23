class SetRemitCodeIndexToPrescriptions < ActiveRecord::Migration[5.1]
  def change
    add_index :prescriptions, :remit_code, unique: true
  end
end
