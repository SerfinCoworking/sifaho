class AddSnomedConceptToProducts < ActiveRecord::Migration[5.2]
  def change
    add_reference :products, :snomed_concept, foreign_key: true, index: true
  end
end
