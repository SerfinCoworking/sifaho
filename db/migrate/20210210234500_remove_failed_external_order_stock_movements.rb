class RemoveFailedExternalOrderStockMovements < ActiveRecord::Migration[5.2]
  def change
    @discount_movements = StockMovement.where(adds: false, order_type: "ExternalOrder") 
    actual_count = @discount_movements.count
    puts "Movimientos de baja de stock: "+actual_count.to_s
    @discount_movements.find_each do |movement|
      if movement.order.provision_en_camino? || movement.order.provision_entregada?
        puts "Movimiento id: "+movement.id.to_s
        if movement.order.applicant_sector == movement.stock.sector
          puts "Movimiento a eliminar: "+movement.id.to_s
          movement.destroy!
        end
      end
    end

    puts "Se eliminaron: "+(actual_count - StockMovement.where(adds: false, order_type: "ExternalOrder").count).to_s+" y quedaron: "+(Stockmovement.where(adds: false, order_type: "ExternalOrder").count - actual_count).to_s
  end
end
