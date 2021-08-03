class AddIndexToSnomedConcepts < ActiveRecord::Migration[5.2]
  def change
    add_index :snomed_concepts, [:concept_id, :term], unique: true
  end
end
