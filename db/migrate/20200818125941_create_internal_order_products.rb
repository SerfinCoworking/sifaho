class CreateInternalOrderProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :internal_order_products do |t|
      t.references :internal_order, index: true
      t.references :product, index: true
      t.integer :request_quantity
      t.integer :delivery_quantity
      t.text :provider_observation
      t.text :applicant_observation

      t.timestamps
    end
    add_index :internal_order_products, [:internal_order_id, :product_id], :unique => true, name: "unique_product_on_internal_order_products"
  end
end
