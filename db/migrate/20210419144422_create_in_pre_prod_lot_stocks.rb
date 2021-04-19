class CreateInPreProdLotStocks < ActiveRecord::Migration[5.2]
  def change
    create_table :in_pre_prod_lot_stocks do |t|
      t.references :inpatient_prescription_product, index: { name: 'inpatient_prescription_product' }
      t.references :lot_stock, index: true
      t.references :dispensed_by, index: true
      t.integer :quantity

      t.timestamps
    end
  end
end
