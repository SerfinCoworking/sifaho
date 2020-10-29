class CreateChronicPrescriptionProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :chronic_prescription_products do |t|
      t.references :chronic_dispensation, index: true
      t.references :product, index: true
      
      t.integer :request_quantity
      t.integer :delivery_quantity

      t.text :observation

      t.timestamps
    end
  end
end
