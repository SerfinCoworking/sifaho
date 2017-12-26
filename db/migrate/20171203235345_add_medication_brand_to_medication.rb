class AddMedicationBrandToMedication < ActiveRecord::Migration[5.1]
  def change
    add_reference :medications, :medication_brand, foreign_key: true
  end
end
