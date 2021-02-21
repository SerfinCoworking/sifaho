class CreateLotArchives < ActiveRecord::Migration[5.2]
  def change
    create_table :lot_archives do |t|
      t.references :user, index: true
      t.references :lot_stock, index: true      
      t.integer :status, default: 0
      t.integer :quantity
      t.text :observation
      t.timestamps
    end
  end
end
