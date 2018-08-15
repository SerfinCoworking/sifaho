class CreateInternalOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :internal_orders do |t|
      t.datetime :date_delivered
      t.datetime :date_received
      t.text :observation
      t.column :status, :integer, default: 0

      t.timestamps
    end
    add_reference :internal_orders, :sector, foreign_key: true
    add_reference :internal_orders, :provider, index: true
    add_reference :internal_orders, :applicant, index: true
    add_column :internal_orders, :deleted_at, :datetime
    add_index :internal_orders, :deleted_at
  end
end
