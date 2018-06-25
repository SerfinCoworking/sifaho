class CreateMedications < ActiveRecord::Migration[5.1]
  def change
    create_table :medications do |t|
      t.integer :quantity
      t.integer :initial_quantity
      t.datetime :expiry_date
      t.datetime :date_received
      t.column :status, :integer, default: 0

      t.timestamps
    end
    add_reference :medications, :medication_brand, foreign_key: true
  end
end
