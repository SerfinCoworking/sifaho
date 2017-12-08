class AddMedicationBrandToMedication < ActiveRecord::Migration[5.1]
  def change
    add_reference :medications, :medication_brand
  end
end
