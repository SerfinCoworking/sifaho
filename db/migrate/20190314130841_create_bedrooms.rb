class CreateBedrooms < ActiveRecord::Migration[5.2]
  def change
    create_table :bedrooms do |t|
      t.string :name
      t.references :sector, index: true

      t.timestamps
    end
  end
end
