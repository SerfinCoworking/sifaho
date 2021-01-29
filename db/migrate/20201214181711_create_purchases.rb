class CreatePurchases < ActiveRecord::Migration[5.2]
  def change
    create_table :purchases do |t|
      t.references :applicant_sector, index: true
      t.references :provider_sector, index: true
      t.references :area, index: true
      t.integer :code_number
      t.string :remit_code
      t.text :observation
      t.integer :status
      t.datetime :received_date
      t.timestamps
    end
  end
end
