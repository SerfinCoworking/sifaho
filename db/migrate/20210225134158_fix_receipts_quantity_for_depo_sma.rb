class FixReceiptsQuantityForDepoSma < ActiveRecord::Migration[5.2]
  def up
    # Buscamos todos los recibos del establecimiento SMA sector deposito
    ExternalOrderBak.recibo.recibo_realizado.each do |receipt|
      new_receipt = Receipt.find_by_code(receipt.remit_code)
      StockMovement.where(order_type: "Receipt", order_id: new_receipt.id).destroy_all
      new_receipt.receipt_products.destroy_all
      puts "Recibo: #{new_receipt.id} - Code: #{new_receipt.code} - estado: #{new_receipt.status} - cantidad productos: #{receipt.quantity_ord_supply_lots.count}"
      receipt.quantity_ord_supply_lots.each do |qosl|
        product_id = Product.where(code: qosl.supply_id).first.id

        # Se busca el primer stock del sector que coincida con el producto
        stock = new_receipt.applicant_sector.stocks.where(product_id: product_id).first
        # Se busca el primer lote que coincida con los parámetros ingresados en la relación
        lot = Lot.where( product_id: product_id, laboratory_id: qosl.laboratory_id, code: qosl.lot_code, expiry_date: qosl.expiry_date).first
        
        # Una vez encontrados el lote y el stock, se busca el lote en stock para asignarla a la relación
        if lot.present? && stock.present?
          lot_stock_received = LotStock.where( stock_id: stock.id, lot_id: lot.id).first
          
          if lot_stock_received.present?
            receipt_prod = new_receipt.receipt_products.build
            receipt_prod.product_id = product_id
            receipt_prod.quantity = qosl.delivered_quantity
            receipt_prod.laboratory_id = qosl.laboratory_id
            receipt_prod.lot_code = qosl.lot_code
            receipt_prod.expiry_date = qosl.expiry_date
            receipt_prod.created_at = qosl.created_at
            receipt_prod.updated_at = qosl.updated_at
            receipt_prod.lot_stock_id = lot_stock_received.id
          else

            puts "No se encontró el lot_stock para qosl id: #{qosl.id}"
          end
        end
      end
      new_receipt.save(validate: false)

      # Iterate through the persisted receipt products and create stock movements
      new_receipt.receipt_products.each do |receipt_product|
        puts "Recibo: #{new_receipt.id} - Lot-stock: #{receipt_product.lot_stock.present? ? receipt_product.lot_stock.id : 'sin lote'} - Receipt Product id: #{receipt_product.id}"
        # controlamos que exista el lot_stock y creamos el movimiento
        if receipt_product.lot_stock.present?
          StockMovement.create!(
            stock: receipt_product.lot_stock.stock, 
            order: new_receipt, 
            lot_stock: receipt_product.lot_stock, 
            quantity: receipt_product.quantity,
            adds: true,
            created_at: new_receipt.received_date,
            updated_at: receipt_product.updated_at
          )
        end
      end
    end
    puts "Se migraron #{ExternalOrderBak.recibo.recibo_realizado.count.to_s} de #{Receipt.count.to_s} recibos".colorize(background: :green)
  end

  def down

  end
end
