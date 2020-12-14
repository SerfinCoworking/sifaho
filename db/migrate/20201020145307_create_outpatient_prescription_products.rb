class CreateOutpatientPrescriptionProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :outpatient_prescription_products do |t|
      t.references :outpatient_prescription, index: {name: :unique_out_pres_prod_on_outpatient_prescriptions}
      t.references :product, index: true
      t.integer :request_quantity
      t.integer :delivery_quantity
      t.text :observation
      t.timestamps
    end
  end
end
