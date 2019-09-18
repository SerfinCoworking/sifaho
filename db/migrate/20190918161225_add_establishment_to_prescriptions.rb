class AddEstablishmentToPrescriptions < ActiveRecord::Migration[5.2]
  def change
    add_reference :prescriptions, :establishment, foreign_key: true
  end
end
