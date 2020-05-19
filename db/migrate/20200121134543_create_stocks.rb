class CreateStocks < ActiveRecord::Migration[5.2]
  def change
    create_table :stocks do |t|
      t.references :sector, index: true
      t.references :product, index: true
      t.integer :quantity

      t.timestamps
    end
  end
end