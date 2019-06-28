class AddAddressToPatient < ActiveRecord::Migration[5.2]
  def change
    add_reference :patients, :address, foreign_key: true
  end
end
