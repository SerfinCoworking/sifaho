namespace :batch do
  desc 'Migrate receipts'
  task migrate_receipts: :environment do
    Receipt.find_each.each do |order|
      order.destroy
    end
    
    puts "Comienza migración de "+ExternalOrderBak.recibo.count.to_s+" recibos de establecimiento"
    
    # Get all solicitud abastecimiento and despachos
    ExternalOrderBak.recibo.each do |recibo|
      if recibo.quantity_ord_supply_lots.present?
        new_receipt = Receipt.new(
          id: recibo.id,
          code: recibo.remit_code,
          applicant_sector_id: recibo.applicant_sector_id,
          provider_sector_id: recibo.provider_sector_id,
          created_by_id: recibo.created_by_id,
          received_by_id: recibo.received_by_id,
          observation: recibo.observation,
          received_date: recibo.date_received,
          created_at: recibo.created_at,
          updated_at: recibo.updated_at,
        )

        if recibo.recibo_realizado?
          new_receipt.status = 'recibido'
        elsif recibo.recibo_auditoria?
          new_receipt.status = 'auditoria'
        end

        recibo.quantity_ord_supply_lots.each do |qosl|
          product_id = Product.where(code: qosl.supply_id).first.id

          receipt_prod = new_receipt.receipt_products.build
          receipt_prod.product_id = product_id

          recibo.quantity_ord_supply_lots.each do |qosl|
            receipt_prod.product_id = product_id
            receipt_prod.quantity = qosl.delivered_quantity
            receipt_prod.laboratory_id = qosl.laboratory_id
            receipt_prod.lot_code = qosl.lot_code
            receipt_prod.expiry_date = qosl.expiry_date
            receipt_prod.created_at = qosl.created_at
            receipt_prod.updated_at = qosl.updated_at
          
            # Se busca el primer stock del sector que coincida con el producto
            stock = new_receipt.applicant_sector.stocks.where(product_id: product_id).first
            # Se busca el primer lote que coincida con los parámetros ingresados en la relación
            lot = Lot.where( product_id: product_id, laboratory_id: qosl.laboratory_id, code: qosl.lot_code, expiry_date: qosl.expiry_date).first
            
            # Una vez encontrados el lote y el stock, se busca el lote en stock para asignarla a la relación
            if lot.present? && stock.present?
              lot_stock_received = LotStock.where( stock_id: stock.id, lot_id: lot.id).first
              receipt_prod.lot_stock_id = lot_stock_received.present? ? lot_stock_received.id : ''
            end
          end
        end

        if new_receipt.receipt_products.size > 0
          if new_receipt.valid?(:code)
            new_receipt.save!
          else
            new_receipt.code = new_receipt.code+"_bis"
            new_receipt.save!
          end
        end

        recibo.movements.each do |movement|
          ReceiptMovement.create(
            user_id: movement.user_id,
            receipt_id: movement.external_order_id,
            sector_id: movement.sector_id,
            action: movement.action,
            created_at: movement.created_at,
            updated_at: movement.updated_at
          )
        end
      end
    end
    puts "Se migraron "+Receipt.count.to_s+" de "+ExternalOrderBak.recibo.count.to_s+" recibos"
  end
end