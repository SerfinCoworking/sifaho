class CreateInternalOrderBaks < ActiveRecord::Migration[5.2]
  def change
    create_table :internal_order_baks do |t|
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
      t.string :remit_code

      t.timestamps
    end
    add_column :internal_order_baks, :deleted_at, :datetime
    add_index :internal_order_baks, :deleted_at
  end
end
