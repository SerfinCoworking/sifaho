class CreateQuantitySupplyRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :quantity_supply_requests do |t|
      t.integer :supply_id
      t.references :quantifiable, polymorphic: true, index: { name: 'quant_sup_req_poly' }
      t.integer :quantity
      t.integer :daily_dose
      t.integer :treatment_duration

      t.timestamps
    end
  end
end
