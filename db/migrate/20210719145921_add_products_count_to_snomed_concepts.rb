class AddProductsCountToSnomedConcepts < ActiveRecord::Migration[5.2]
  def change
    add_column :snomed_concepts, :products_count, :integer, default: 0, null: false
  end
end
