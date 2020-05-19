class CreateAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :addresses do |t|
      t.string :postal_code
      t.text :line
      t.references :city, foreign_key: true
      t.references :country, index: true
      t.references :state, index: true

      t.timestamps
    end
    add_reference :patients, :address, foreign_key: true
  end
end