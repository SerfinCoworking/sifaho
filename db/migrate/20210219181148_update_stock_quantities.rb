class UpdateStockQuantities < ActiveRecord::Migration[5.2]
  def change
    Stock.find_each do |stock|
      puts "Sock before total quantity: "+stock.total_quantity.to_s
      puts "Sock before reserved quantity: "+stock.reserved_quantity.to_s
      stock.refresh_quantity
      puts "Sock after total quantity: "+stock.total_quantity.to_s
      puts "Sock after reserved quantity: "+stock.reserved_quantity.to_s
    end
  end
end
