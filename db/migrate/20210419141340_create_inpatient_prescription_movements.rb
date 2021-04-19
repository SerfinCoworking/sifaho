class CreateInpatientPrescriptionMovements < ActiveRecord::Migration[5.2]
  def change
    create_table :inpatient_prescription_movements do |t|
      t.references :order, index: true
      t.references :order_product, index: true
      t.references :user, index: true
      t.references :sector, index: true
      t.string :action

      t.timestamps
    end
  end
end
