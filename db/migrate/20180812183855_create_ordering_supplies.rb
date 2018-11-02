class CreateOrderingSupplies < ActiveRecord::Migration[5.1]
  def change
    create_table :ordering_supplies do |t|
      t.references :applicant_sector, index: true
      t.references :provider_sector, index: true
      t.references :audited_by, index: true
      t.references :accepted_by, index: true
      t.references :sent_by, index: true
      t.references :received_by, index: true
      t.references :created_by, index: true
      t.text :observation
      t.string :remit_code

      t.datetime :sent_date
      t.datetime :accepted_date
      t.datetime :date_received
      t.datetime :requested_date

      t.integer :status, default: 0
      t.ineger :order_type, default: 0

      t.timestamps
    end
    add_column :ordering_supplies, :deleted_at, :datetime
    add_index :ordering_supplies, :deleted_at
  end
end