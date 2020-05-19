class CreateExternalOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :external_orders do |t|
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
      t.integer :order_type, default: 0

      t.timestamps
    end
    add_column :external_orders, :deleted_at, :datetime
    add_index :external_orders, :deleted_at
    add_index :external_orders, :remit_code, unique: true
    add_reference :external_orders, :sent_request_by, index: true
  end
end