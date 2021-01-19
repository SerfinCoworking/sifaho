class CreateReceipts < ActiveRecord::Migration[5.2]
  def change
    create_table :receipts do |t|
      t.string :code
      t.references :provider_sector, index: true
      t.references :applicant_sector, index: true
      t.references :created_by, index: true
      t.references :received_by, index: true
      t.integer :status, default: 0
      t.text :observation
      t.datetime :received_date
      t.timestamps
    end
  end
end
