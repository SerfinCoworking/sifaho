class CreateStockMovements < ActiveRecord::Migration[5.2]
  def change
    create_table :stock_movements do |t|
      t.references :order, polymorphic: true, index: { name: 'order_polymorphic' }
      t.references :stock, index: true
      t.references :lot_stock, index: true
      t.integer :quantity, default: 0
      t.boolean :adds, default: false

      t.timestamps
    end
  end
end
