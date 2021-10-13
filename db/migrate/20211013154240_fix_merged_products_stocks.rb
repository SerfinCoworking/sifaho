class FixMergedProductsStocks < ActiveRecord::Migration[5.2]
  def change
    # Each merged product
    UnifyProduct.merged.find_each do |unified_product|
    
      # Take each orphan stock of origin product
      unified_product.origin_product.stocks.each do | stock_origin |
        # Find target stock by "target product" and with same sector as stock_origin or create new stock
        # with quantities in zero.
        target_stock = Stock.create_with( quantity: 0,
                                          total_quantity: 0,
                                          reserved_quantity: 0
                                        ).find_or_create_by(product_id: unified_product.target_product.id, sector_id: stock_origin.sector_id)
        
        # Stock could be found with quantities, and we need sum with stock_origin quantities
        sum_quantity = target_stock.quantity + stock_origin.quantity
        sum_total_quantity = target_stock.total_quantity + stock_origin.total_quantity
        sum_reserved_quantity = target_stock.reserved_quantity + stock_origin.reserved_quantity

        target_stock.update_columns(quantity: sum_quantity, total_quantity: sum_total_quantity, reserved_quantity: sum_reserved_quantity)
        
        # finally, update each lot_stock of stock_origin, with target_stock.id
        stock_origin.lot_stocks.each do | lot_stock_origin |
          lot_stock_origin.update_column(:stock_id, target_stock.id)
        end
      end

    end

  end
end