class CreateAreas < ActiveRecord::Migration[5.2]
  def change
    create_table :areas do |t|
      t.string :name
      t.references :parent, index: true

      t.timestamps
    end
    # Add subareas
    add_reference :areas, :parent_area, index: true
    add_reference :areas, :first_area, index: true
  end
end
