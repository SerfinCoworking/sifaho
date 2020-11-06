class CreateOriginalChronicPrescriptionProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :original_chronic_prescription_products do |t|
      t.references :chronic_prescription, index: {name: :unique_chron_pres_on_org_cron_pres_prod}
      t.references :product, index: true
      t.integer :request_quantity
      t.integer :total_request_quantity, :default => 0
      t.integer :total_delivered_quantity, :default => 0
      t.text :observation

      t.timestamps
    end
  end
end
