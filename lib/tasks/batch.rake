namespace :batch do
  desc 'Update lot status'
  task update_lot_status: :environment do
    SupplyLot.all.each do |lot| 
      lot.update_status_without_validate!
    end

    SectorSupplyLot.all.each do |lot| 
      lot.update_status_without_validate!
    end
  end

  desc 'Migrate external orders'
  task migrate_external_orders: :environment do
    ExternalOrder.with_deleted.find_each.each do |order|
      order.destroy!
    end
    ExternalOrder.with_deleted.find_each.each do |order|
      order.really_destroy!
    end

    puts "Comienza migración de "+ExternalOrderBak.solicitud_abastecimiento.count.to_s+" solicitudes y "+ExternalOrderBak.despacho.count.to_s+" despachos de establecimiento"

    # Get all solicitud abastecimiento and despachos
    ExternalOrderBak.without_order_type(2).find_each do |solicitud|
      if solicitud.quantity_ord_supply_lots.present?
        external_order = ExternalOrder.new(
          id: solicitud.id,
          observation: solicitud.observation,
          date_received: solicitud.date_received,
          created_at: solicitud.created_at,
          updated_at: solicitud.updated_at,
          deleted_at: solicitud.deleted_at,
          applicant_sector_id: solicitud.applicant_sector_id,
          provider_sector_id: solicitud.provider_sector_id,
          requested_date: solicitud.requested_date,
          sent_date: solicitud.sent_date,
          status: solicitud.status,
          audited_by_id: solicitud.audited_by_id,
          accepted_by_id: solicitud.accepted_by_id,
          sent_by_id: solicitud.sent_by_id,
          received_by_id: solicitud.received_by_id,
          accepted_date: solicitud.accepted_date,
          created_by_id: solicitud.created_by_id,
          remit_code: solicitud.remit_code,
          sent_request_by_id: solicitud.sent_request_by_id,
          rejected_by_id: solicitud.rejected_by_id,
        )

        if solicitud.solicitud_abastecimiento?
          external_order.order_type = 'solicitud'
        elsif solicitud.despacho?
          external_order.order_type = 'provision'
        end

        solicitud.quantity_ord_supply_lots.each do |qosl|
          product_id = Product.where(code: qosl.supply_id).first.id

          # Check if qosl has a selected lot and was created on LotStock
          if solicitud.provision_en_camino? || solicitud.provision_entregada? || solicitud.proveedor_aceptado?

            if qosl.sector_supply_lot_id.present? && LotStock.where(id: qosl.sector_supply_lot_id).present?

              # Check if the product was already created
              if external_order.external_order_products.to_ary.select { |eop| eop.product_id == product_id }.size == 0
                ext_ord_prod = external_order.external_order_products.build
                ext_ord_prod.product_id = product_id

                solicitud.quantity_ord_supply_lots.where(supply_id: qosl.supply_id).each do |qosl_with_same_supply|
                  if ext_ord_prod.delivery_quantity.present?
                    ext_ord_prod.delivery_quantity += qosl_with_same_supply.delivered_quantity
                  else
                    ext_ord_prod.delivery_quantity = 0
                    ext_ord_prod.delivery_quantity += qosl_with_same_supply.delivered_quantity
                  end
                  if ext_ord_prod.request_quantity.present?
                    ext_ord_prod.request_quantity += qosl_with_same_supply.delivered_quantity
                  else
                    ext_ord_prod.request_quantity = 0
                    ext_ord_prod.request_quantity += qosl_with_same_supply.delivered_quantity
                  end
                  if qosl_with_same_supply.provider_observation.present?; ext_ord_prod.provider_observation = qosl_with_same_supply.provider_observation; end
                  if qosl_with_same_supply.applicant_observation.present?; ext_ord_prod.applicant_observation = qosl_with_same_supply.applicant_observation; end
                  ext_ord_prod.created_at = qosl_with_same_supply.created_at
                  ext_ord_prod.updated_at = qosl_with_same_supply.updated_at
      
                  if qosl_with_same_supply.sector_supply_lot_id.present? && LotStock.where(id: qosl_with_same_supply.sector_supply_lot_id).present?
                    ext_ord_prod.order_prod_lot_stocks.build(
                      lot_stock_id: qosl_with_same_supply.sector_supply_lot_id,
                      quantity: qosl_with_same_supply.delivered_quantity,
                      created_at: qosl_with_same_supply.created_at,
                      updated_at: qosl_with_same_supply.updated_at
                    )
                  else
                    ext_ord_prod.delivery_quantity -= qosl_with_same_supply.delivered_quantity 
                  end
                end
              end
            end
          else
            # Check if the product was already created
            if external_order.external_order_products.to_ary.select { |eop| eop.product_id == product_id }.size == 0
              ext_ord_prod = external_order.external_order_products.build
              ext_ord_prod.product_id = product_id

              solicitud.quantity_ord_supply_lots.where(supply_id: qosl.supply_id).each do |qosl_with_same_supply|
                if ext_ord_prod.delivery_quantity.present?
                  ext_ord_prod.delivery_quantity += qosl_with_same_supply.delivered_quantity 
                else
                  ext_ord_prod.delivery_quantity = 0
                  ext_ord_prod.delivery_quantity += qosl_with_same_supply.delivered_quantity
                end
                if ext_ord_prod.request_quantity.present? 
                  ext_ord_prod.request_quantity += qosl_with_same_supply.delivered_quantity 
                else
                  ext_ord_prod.request_quantity = 0
                  ext_ord_prod.request_quantity += qosl_with_same_supply.delivered_quantity
                end
                if qosl_with_same_supply.provider_observation.present?; ext_ord_prod.provider_observation = qosl_with_same_supply.provider_observation; end
                if qosl_with_same_supply.applicant_observation.present?; ext_ord_prod.applicant_observation = qosl_with_same_supply.applicant_observation; end
                ext_ord_prod.created_at = qosl_with_same_supply.created_at
                ext_ord_prod.updated_at = qosl_with_same_supply.updated_at
    
                if qosl_with_same_supply.sector_supply_lot_id.present? && LotStock.where(id: qosl_with_same_supply.sector_supply_lot_id).present?
                  ext_ord_prod.order_prod_lot_stocks.build(
                    lot_stock_id: qosl_with_same_supply.sector_supply_lot_id,
                    quantity: qosl_with_same_supply.delivered_quantity,
                    created_at: qosl_with_same_supply.created_at,
                    updated_at: qosl_with_same_supply.updated_at
                  )
                else
                  ext_ord_prod.delivery_quantity -= qosl_with_same_supply.delivered_quantity 
                end
              end
            end
          end
        end

        if external_order.external_order_products.size > 0
          external_order.save
          solicitud.movements.each do |solicitud|
            ExternalOrderMovement.create(
              user_id: solicitud.user_id,
              external_order_id: solicitud.external_order_id,
              sector_id: solicitud.sector_id,
              action: solicitud.action,
              created_at: solicitud.created_at,
              updated_at: solicitud.updated_at
            )
          end
        end
      end
    end
    puts "Se migraron "+ExternalOrder.solicitud.count.to_s+" de "+ExternalOrderBak.solicitud_abastecimiento.count.to_s+" solicitudes"
    puts "Se migraron "+ExternalOrder.provision.count.to_s+" de "+ExternalOrderBak.despacho.count.to_s+" despachos"
  end






  desc 'Migrate receipts'
  task migrate_receipts: :environment do
    Receipt.find_each.each do |order|
      order.destroy
    end
    
    puts "Comienza migración de "+ExternalOrderBak.recibo.count.to_s+" recibos de establecimiento"
    
    # Get all solicitud abastecimiento and despachos
    ExternalOrderBak.recibo.each do |recibo|
      puts "Recibo id: "+recibo.id.to_s
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
          puts new_receipt.status
          if new_receipt.valid?(:code)
            new_receipt.save!
            puts "Código válido"
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

  # Receipt products
  # t.bigint "receipt_id"-
  # t.bigint "lot_stock_id"-
  # t.bigint "product_id"-
  # t.bigint "laboratory_id"-
  # t.integer "quantity"-
  # t.string "lot_code"-
  # t.date "expiry_date"
  # t.datetime "created_at", null: false
  # t.datetime "updated_at", null: false

  # t.integer "supply_lot"
  # t.string "quantifiable_type"
  # t.bigint "quantifiable_id"
  # t.integer "requested_quantity", default: 0
  # t.integer "delivered_quantity", default: 0
  # t.datetime "created_at", null: false
  # t.datetime "updated_at", null: false
  # t.bigint "sector_supply_lot_id"
  # t.bigint "supply_id"
  # t.bigint "supply_lot_id"
  # t.date "expiry_date"
  # t.string "lot_code"
  # t.bigint "laboratory_id"
  # t.integer "status", default: 0
  # t.text "applicant_observation"
  # t.text "provider_observation"
  # t.integer "treatment_duration"
  # t.integer "daily_dose"
  # t.datetime "dispensed_at"
  # t.bigint "cronic_dispensation_id"
end
