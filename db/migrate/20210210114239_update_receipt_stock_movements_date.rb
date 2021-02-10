class UpdateReceiptStockMovementsDate < ActiveRecord::Migration[5.2]
  def up
    # Traemos únicamente los movimientos de stock de recibos realizados el 04/02/2021
    @incorrect_stock_movements = StockMovement
      .where(order_type: 'Receipt')
      .since_date("04/02/2021").to_date("04/02/2021")
    puts "Cantidad de movimientos incorrectos en esa fecha: "+@incorrect_stock_movements.count.to_s
    puts "Comienzo de interación..."
    @incorrect_stock_movements.each do |incorrect_stock_movement|
      puts "Movimiento id: "+incorrect_stock_movement.id.to_s+" fecha: "+incorrect_stock_movement.created_at.strftime("%d/%m/%Y")
      if incorrect_stock_movement.order.received_date.present?
        incorrect_stock_movement.created_at = incorrect_stock_movement.order.received_date
      end
      puts "Fecha correcta: "+incorrect_stock_movement.created_at.strftime("%d/%m/%Y")
      incorrect_stock_movement.save(validate: false)
    end
  end

  def down

  end
end
