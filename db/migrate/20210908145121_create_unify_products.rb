class CreateUnifyProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :unify_products do |t|
      t.references :origin_product, foreign_key: { to_table: :products }
      t.references :target_product, foreign_key: { to_table: :products }
      t.integer :status, default: 0
      t.text :observation

      t.timestamps
    end
  end
end
