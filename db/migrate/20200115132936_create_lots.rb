class CreateLots < ActiveRecord::Migration[5.2]
  def change
    create_table :lots do |t|
      t.references :product, foreign_key: true
      t.references :laboratory, foreign_key: true
      t.string :code
      t.datetime :expiry_date

      t.timestamps
    end
    add_column :lots, :deleted_at, :datetime
    add_index :lots, :deleted_at
  end
end
