class AddParentToAreas < ActiveRecord::Migration[5.2]
  def change
    add_reference :areas, :parent, index: true
  end
end
