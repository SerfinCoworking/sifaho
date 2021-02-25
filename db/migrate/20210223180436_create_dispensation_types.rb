class CreateDispensationTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :dispensation_types do |t|
      t.references :chronic_dispensation, index: true
      t.references :original_chronic_prescription_product, index: {name: :unique_org_chron_pres_on_dispensation_types}
      t.integer :quantity_type, default: 0
      t.integer :quantity
      t.timestamps
    end
  end
end
