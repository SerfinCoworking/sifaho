class CreateSupplies < ActiveRecord::Migration[5.1]
  def change
    create_table :supplies do |t|
      t.string :name
      t.string :description
      t.string :observation
      t.string :unity, :limit => 100
      t.boolean :needs_expiration
      t.boolean :active_alarm
      t.integer :period_alarm
      t.integer :expiration_alarm
      t.integer :quantity_alarm
      t.integer :period_control
      t.boolean :is_active

      t.timestamps
    end
    add_reference :supplies, :supply_area, foreign_key: true
    add_column :supplies, :deleted_at, :datetime
    add_index :supplies, :deleted_at
  end
end
