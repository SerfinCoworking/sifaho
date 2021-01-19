namespace :batch do
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
        end
      end
    end
    puts "Se migraron "+ExternalOrder.solicitud.count.to_s+" de "+ExternalOrderBak.solicitud_abastecimiento.count.to_s+" solicitudes"
    puts "Se migraron "+ExternalOrder.provision.count.to_s+" de "+ExternalOrderBak.despacho.count.to_s+" despachos"
  end
end