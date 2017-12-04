class AddMedicationToVademecum < ActiveRecord::Migration[5.1]
  def change
    add_reference :vademecums, :medication, foreign_key: true
  end
end
