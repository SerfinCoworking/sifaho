class CreatePurchaseProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :purchase_products do |t|
      t.references :purchase, index: true
      t.references :product, index: true
      t.integer :request_quantity
      t.text :observation
      t.string :line
      t.timestamps
    end
  end
end
