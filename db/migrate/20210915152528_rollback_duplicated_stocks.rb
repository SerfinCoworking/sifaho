class RollbackDuplicatedStocks < ActiveRecord::Migration[5.2]
  def change
    UnifyProduct.merged.find_each do |unified_product|
      Stock.where(product_id: unified_product.target_product_id).find_each do |stock|
        repeated_stocks = Stock.where(sector_id: stock.sector_id, product_id: stock.product_id)

        if repeated_stocks.count > 1
          puts 'Stock repetido!'
          origin_stock = if repeated_stocks.first.quantity > repeated_stocks.second.quantity
                           repeated_stocks.second
                         else
                           repeated_stocks.first
                         end
          origin_stock.product_id = unified_product.origin_product.id
          origin_stock.save!
        end
      end
    end
  end
end
