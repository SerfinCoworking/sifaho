class ReturnFailedStockMovements < ActiveRecord::Migration[5.2]
  def change
    receipt = Receipt.find_by_code('RE20210309084013')
    StockMovement.where(order_id: receipt.id, order_type: 'Receipt').each do |stock_movement|
      puts "Stock movement id: "+stock_movement.id.to_s
      puts "Cantidad: "+stock_movement.quantity.to_s
      unless stock_movement.lot_stock.id == 36809
        stock_movement.lot_stock.decrement(stock_movement.quantity)
      end
      stock_movement.destroy
    end
  end
end
