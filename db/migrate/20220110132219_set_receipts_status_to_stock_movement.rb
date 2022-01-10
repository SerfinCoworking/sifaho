class SetReceiptsStatusToStockMovement < ActiveRecord::Migration[5.2]
  def change
     # Decrement Stock
     increment_stock_movements = StockMovement.where(order_type: 'Receipt', adds: true)
     increment_stock_movements.each { |dsm| dsm.update(status: 'recibido') }
  end
end
