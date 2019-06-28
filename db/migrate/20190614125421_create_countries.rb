class CreateCountries < ActiveRecord::Migration[5.2]
  def change
    create_table :countries do |t|
      t.string :name
      t.string :iso2
      t.string :iso3
      t.string :phone_code
    end
  end
end
