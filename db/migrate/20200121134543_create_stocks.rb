class CreateStocks < ActiveRecord::Migration[5.2]
  def change
    create_table :stocks do |t|
      t.references :supply, foreign_key: true
      t.references :sector, foreign_key: true
      t.integer :quantity

      t.timestamps
    end
  end
end
