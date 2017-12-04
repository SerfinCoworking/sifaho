class CreateMedicationBrands < ActiveRecord::Migration[5.1]
  def change
    create_table :medication_brands do |t|
      t.string :name
      t.string :description
      t.references :laboratory

      t.timestamps
    end
  end
end
