class CreateExternalOrderProduct < ActiveRecord::Migration[5.2]
  def change
    create_table :external_order_products do |t|
    
      t.references :external_order, index: true
      t.references :product, index: true
      
      t.integer :request_quantity
      t.integer :delivery_quantity
      t.text :provider_observation
      t.text :applicant_observation
      t.timestamps
    end
    
    add_index :external_order_products, [:external_order_id, :product_id], :unique => true, name: "unique_product_on_external_order_products"
  end

end
