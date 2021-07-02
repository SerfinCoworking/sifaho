class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.references :unity, index: true
      t.references :area, index: true
      t.string :code, index: true, unique: true
      t.string :name
      t.text :description
      t.text :observation

      t.timestamps
    end
  end
end
  