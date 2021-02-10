class GenerateStockMovementsToSentExternalOrders < ActiveRecord::Migration[5.2]
  def up
    sent_orders = ExternalOrder
      .where(status: [ 4, 5])
      .sent_date_since(DateTime.new(2021,02,4).beginning_of_day)
      .sent_date_to(DateTime.new(2021,02,5).end_of_day)
    
    sent_orders.each do |sent_order| 
      sent_order.order_products.each do |order_product|
        order_product.order_prod_lot_stocks.each do |opls|
          
          # Check if the movements was already created
          exist_movement = opls
            .lot_stock
            .stock
            .movements
            .since_date("04/02/2021")
            .to_date("05/02/2021")
            .where(
              order_type: "ExternalOrder",
              order_id: sent_order.id,
              lot_stock_id: opls.lot_stock.id
            ).present?

          puts "Check if the movement exists: "+exist_movement.to_s

          unless exist_movement
            # opls.lot_stock.stock.create_stock_movement(sent_order, opls.lot_stock, opls.quantity, false)
            StockMovement.create(
              stock: opls.lot_stock.stock, 
              order: sent_order, 
              lot_stock: opls.lot_stock, 
              quantity: opls.quantity, 
              adds: false, 
              created_at: sent_order.sent_date
            )
            puts "Movimiento creado!"
          end
        end
      end
    end

  end

  def down
    
  end
end
