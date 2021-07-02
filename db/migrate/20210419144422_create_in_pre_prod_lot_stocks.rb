class CreateInPreProdLotStocks < ActiveRecord::Migration[5.2]
  def change
    create_table :in_pre_prod_lot_stocks do |t|
      t.references :inpatient_prescription_product, index: { name: 'inpatient_prescription_product' }
      t.references :lot_stock, index: true
      t.references :supplied_by_sector, index: true      
      t.integer :available_quantity
      t.integer :reserved_quantity, default: 0

      t.timestamps
    end
  end
end
