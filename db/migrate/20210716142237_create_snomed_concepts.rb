class CreateSnomedConcepts < ActiveRecord::Migration[5.2]
  def change
    create_table :snomed_concepts do |t|
      t.string :concept_id, index: true, unique: true
      t.string :term
      t.text :fsn
      t.string :semantic_tag

      t.timestamps
    end
  end
end
