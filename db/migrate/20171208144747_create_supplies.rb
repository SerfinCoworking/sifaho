class CreateSupplies < ActiveRecord::Migration[5.1]
  def change
    create_table :supplies do |t|
      t.string :name
      t.string :description
      t.string :observation
      t.string :unity
      t.boolean :needs_expiration
      t.boolean :is_active

      t.timestamps
    end
    add_reference :supplies, :supply_area, index: true, default: 38
    add_column :supplies, :deleted_at, :datetime
    add_index :supplies, :deleted_at
  end
end
