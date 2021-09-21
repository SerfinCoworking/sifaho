class UpdateOrderProdLotStocksReservedQuantity < ActiveRecord::Migration[5.2]
  def change
    ExternalOrder.proveedor_aceptado.find_each do |order|
      order.ext_ord_prod_lot_stocks.find_each do |ord_prod_lot_stock|
        ord_prod_lot_stock.update_column(:reserved_quantity, ord_prod_lot_stock.quantity)
      end
    end
  end
end
