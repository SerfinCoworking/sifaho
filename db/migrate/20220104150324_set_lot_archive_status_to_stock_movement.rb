class SetLotArchiveStatusToStockMovement < ActiveRecord::Migration[5.2]
  def change
    # Decrement Stock
    decrement_stock_movements = StockMovement.where(order_type: 'LotArchive', adds: false)
    decrement_stock_movements.each do |dsm|
      dsm.update(status: 'archivado')
    end

    # Increment Stock
    increment_stock_movements = StockMovement.where(order_type: 'LotArchive', adds: true)
    increment_stock_movements.each do |ism|
      ism.update(status: 'retornado')
    end
  end
end
