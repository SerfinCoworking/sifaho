class AddFinishedByAttributesToOriginalChronicPrescriptionProducts < ActiveRecord::Migration[5.2]
  def change
    add_reference :original_chronic_prescription_products, :finished_by_professional, index: { name: 'original_product_finished_by_professional'}
    add_column :original_chronic_prescription_products, :finished_observation, :text
  end
end
