class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.references :unity, foreign_key: true
      # t.references :area, foreign_key: true
      t.string :code
      t.string :name
      t.text :description
      t.text :observation

      t.timestamps
    end
    add_column :products, :deleted_at, :datetime
    add_index :products, :deleted_at
  end
end
