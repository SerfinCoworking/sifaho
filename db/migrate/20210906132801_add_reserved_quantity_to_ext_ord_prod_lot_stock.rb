class AddReservedQuantityToExtOrdProdLotStock < ActiveRecord::Migration[5.2]
  def change
    add_column :ext_ord_prod_lot_stocks, :reserved_quantity, :integer, default: 0
  end
end
