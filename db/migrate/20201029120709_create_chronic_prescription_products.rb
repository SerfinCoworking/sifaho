class CreateChronicPrescriptionProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :chronic_prescription_products do |t|
      t.references :original_chronic_prescription_product, index: {name: :unique_org_chronic_prescription_product_cpp}
      t.references :chronic_dispensation, index: true
      t.references :product, index: true
      
      t.integer :delivery_quantity

      t.text :observation

      t.timestamps
    end
  end
end
