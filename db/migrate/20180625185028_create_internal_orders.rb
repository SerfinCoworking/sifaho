class CreateInternalOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :internal_orders do |t|
      t.references :provider_sector, index: true
      t.references :applicant_sector, index: true
  
      t.references :audited_by, index: true
      t.references :sent_by, index: true
      t.references :received_by, index: true
      t.references :created_by, index: true
      t.references :rejected_by, index: true
      t.references :sent_request_by, index: true

      t.datetime :sent_date
      t.datetime :requested_date
      t.datetime :date_received
      t.text :observation
      t.column :provider_status, :integer, default: 0
      t.column :applicant_status, :integer, default: 0
      t.integer :status, default: 0
      t.column :order_type, :integer, default: 0
      t.string :remit_code, index: true, unique: true

      t.timestamps
    end
  end
end
