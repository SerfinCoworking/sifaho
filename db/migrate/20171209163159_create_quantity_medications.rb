class CreateQuantityMedications < ActiveRecord::Migration[5.1]
  def change
    create_table :quantity_medications do |t|
      t.integer :medication_id
      t.references :quantifiable, polymorphic: true, index: { name: 'quant_med_poly' }
      t.integer :quantity

      t.timestamps
    end
  end
end
