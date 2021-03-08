class CreatePatientProductStateReports < ActiveRecord::Migration[5.2]
  def change
    create_table :patient_product_state_reports do |t|
      t.datetime :since_date
      t.datetime :to_date
      t.references :product, index: true
      t.references :created_by, index: true

      t.timestamps
    end
  end
end
