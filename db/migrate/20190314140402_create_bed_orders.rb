class CreateBedOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :bed_orders do |t|
      t.references :bedroom, index: true
      t.references :patient, index: true
      t.references :sent_by, index: true
      t.references :created_by, index: true
      t.references :audited_by, index: true
      t.references :received_by, index: true
      t.references :sent_request_by_id, index: true
      t.string :observation
      t.string :remit_code
      
      t.datetime :sent_date
      t.datetime :deleted_at
      t.datetime :date_received
      
      t.integer :status, default: 0
      
      t.timestamps

      t.references :bed, index: true
      t.references :establishment, index: true
      t.references :applicant_sector, index: true
    end
  end
end