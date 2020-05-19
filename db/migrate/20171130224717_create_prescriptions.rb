class CreatePrescriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :prescriptions do |t|
      t.string :remit_code
      t.text :observation
      t.datetime :date_received
      t.datetime :date_dispensed
      t.integer :status, default: 0
      t.integer :order_type, default: 0
      t.datetime :prescribed_date
      t.datetime :expiry_date
      t.integer :times_dispensation
      t.integer :times_dispensed, default: 0
      t.datetime :audited_at
      t.datetime :dispensed_at

      t.references :provider_sector, index: true
      t.references :professional, index: true
      t.references :patient, index: true
      t.references :establishment, index: true

      t.references :created_by, index: true
      t.references :audited_by, index: true
      t.references :dispensed_by, index: true
      

      t.timestamps
    end
    add_column :prescriptions, :deleted_at, :datetime
    add_index :prescriptions, :deleted_at
    add_index :prescriptions, :remit_code, unique: true
  end
end