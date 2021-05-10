class CreateInpatientPrescriptionProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :inpatient_prescription_products do |t|
      t.references :inpatient_prescription, index: { name: 'index_inpatient_prescription' }
      t.references :parent
      t.references :product, index: true
      t.integer :dose_quantity
      t.integer :interval
      t.integer :dose_total
      t.integer :status
      t.text :observation

      t.timestamps
    end
    add_index :inpatient_prescription_products, [:inpatient_prescription_id, :product_id], :unique => true, name: "unique_product_on_inpatient_prescription_products"
  end
end
