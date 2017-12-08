class CreateMedications < ActiveRecord::Migration[5.1]
  def change
    create_table :medications do |t|
      t.integer :quantity
      t.datetime :expiry_date
      t.datetime :date_received

      t.timestamps
    end
  end
end
