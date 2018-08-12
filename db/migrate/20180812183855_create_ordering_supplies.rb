class CreateOrderingSupplies < ActiveRecord::Migration[5.1]
  def change
    create_table :ordering_supplies do |t|
      t.references :sector, foreign_key: true
      t.text :observation
      t.datetime :date_received
      t.integer :status, default: 0

      t.timestamps
    end
    add_reference :ordering_supplies, :responsable, index: true
  end
end
