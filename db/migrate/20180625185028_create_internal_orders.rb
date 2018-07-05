class CreateInternalOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :internal_orders do |t|
      t.datetime :date_delivered
      t.datetime :date_received
      t.text :observation
      t.column :status, :integer, default: 0

      t.timestamps
    end
    add_reference :internal_orders, :responsable, index: true
  end
end
