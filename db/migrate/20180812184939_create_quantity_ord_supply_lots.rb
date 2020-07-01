class CreateQuantityOrdSupplyLots < ActiveRecord::Migration[5.1]
  def change
    create_table :quantity_ord_supply_lots do |t|
      t.string :lot_code
      t.references :quantifiable, polymorphic: true, index: { name: 'quant_ord_sup_lot_poly' }
      t.integer :requested_quantity, default: 0
      t.integer :delivered_quantity, default: 0
      t.integer :status, default: 0
      t.integer :treatment_duration
      t.integer :daily_dose
      t.references :supply, index: true
      t.references :sector_supply_lot, index: true
      t.references :supply_lot, index: true
      t.references :laboratory, index: true
      t.references :cronic_dispensation, index: true

      t.text :applicant_observation
      t.text :provider_observation

      t.datetime :expiry_date
      t.datetime :dispensed_at

      t.timestamps
    end
  end
end