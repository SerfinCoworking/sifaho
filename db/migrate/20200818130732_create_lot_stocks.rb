class CreateLotStocks < ActiveRecord::Migration[5.2]
  def change
    create_table :lot_stocks do |t|
      t.references :lot, index: true
      t.references :stock, index: true
      t.integer :quantity

      t.timestamps
    end
  end
end
