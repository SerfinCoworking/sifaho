class AddSubareasToAreas < ActiveRecord::Migration[5.2]
  def change
    add_reference :areas, :parent_area, index: true
    add_reference :areas, :first_area, index: true
  end
end
