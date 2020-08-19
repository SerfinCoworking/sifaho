class CreateInternalOrderProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :internal_order_products do |t|
      t.references :internal_order, index: true
      t.references :product, index: true
      t.integer :request_quantity
      t.integer :delivery_quantity
      t.text :observation

      t.timestamps
    end
  end
end
