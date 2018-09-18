class CreateInternalOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :internal_orders do |t|
      t.datetime :sent_date
      t.datetime :requested_date
      t.datetime :date_received
      t.text :observation
      t.column :status, :integer, default: 0

      t.timestamps
    end
    add_reference :internal_orders, :provider_sector, index: true
    add_reference :internal_orders, :applicant_sector, index: true
    add_column :internal_orders, :deleted_at, :datetime
    add_index :internal_orders, :deleted_at
  end
end
