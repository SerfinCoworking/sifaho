namespace :batch do
  desc 'Migrate internal order products'
  task migrate_internal_orders: :environment do
    InternalOrderBak.all.each do |old_internal_order|
      new_internal_order = InternalOrder.find(old_internal_order.id)
      puts "Pedido interno id: "+new_internal_order.id.to_s

      if old_internal_order.quantity_ord_supply_lots.present?
        old_internal_order.quantity_ord_supply_lots.each do |qosl|
          product_id = Product.where(code: qosl.supply_id).first.id

          # Check if qosl has a selected lot and was created on LotStock
          if old_internal_order.provision_en_camino? || old_internal_order.provision_entregada?

            if qosl.sector_supply_lot_id.present? && LotStock.where(id: qosl.sector_supply_lot_id).present?

              # Check if the product was already created
              if new_internal_order.internal_order_products.to_ary.select { |iop| iop.product_id == product_id }.size == 0
                int_ord_prod = new_internal_order.internal_order_products.build
                int_ord_prod.product_id = product_id

                old_internal_order.quantity_ord_supply_lots.where(supply_id: qosl.supply_id).each do |qosl_with_same_supply|
                  if int_ord_prod.delivery_quantity.present?
                    int_ord_prod.delivery_quantity += qosl_with_same_supply.delivered_quantity
                  else
                    int_ord_prod.delivery_quantity = 0
                    int_ord_prod.delivery_quantity += qosl_with_same_supply.delivered_quantity
                  end
                  if int_ord_prod.request_quantity.present?
                    int_ord_prod.request_quantity += qosl_with_same_supply.delivered_quantity
                  else
                    int_ord_prod.request_quantity = 0
                    int_ord_prod.request_quantity += qosl_with_same_supply.delivered_quantity
                  end
                  if qosl_with_same_supply.provider_observation.present?; int_ord_prod.provider_observation = qosl_with_same_supply.provider_observation; end
                  if qosl_with_same_supply.applicant_observation.present?; int_ord_prod.applicant_observation = qosl_with_same_supply.applicant_observation; end
                  int_ord_prod.created_at = qosl_with_same_supply.created_at
                  int_ord_prod.updated_at = qosl_with_same_supply.updated_at
      
                  if qosl_with_same_supply.sector_supply_lot_id.present? && LotStock.where(id: qosl_with_same_supply.sector_supply_lot_id).present?
                    int_ord_prod.order_prod_lot_stocks.build(
                      lot_stock_id: qosl_with_same_supply.sector_supply_lot_id,
                      quantity: qosl_with_same_supply.delivered_quantity,
                      created_at: qosl_with_same_supply.created_at,
                      updated_at: qosl_with_same_supply.updated_at
                    )
                  else
                    int_ord_prod.delivery_quantity -= qosl_with_same_supply.delivered_quantity 
                  end
                end
              end
            end
          else
            # Check if the product was already created
            if new_internal_order.internal_order_products.to_ary.select { |iop| iop.product_id == product_id }.size == 0
              int_ord_prod = new_internal_order.internal_order_products.build
              int_ord_prod.product_id = product_id

              old_internal_order.quantity_ord_supply_lots.where(supply_id: qosl.supply_id).each do |qosl_with_same_supply|
                if int_ord_prod.delivery_quantity.present?
                  int_ord_prod.delivery_quantity += qosl_with_same_supply.delivered_quantity 
                else
                  int_ord_prod.delivery_quantity = 0
                  int_ord_prod.delivery_quantity += qosl_with_same_supply.delivered_quantity
                end
                if int_ord_prod.request_quantity.present? 
                  int_ord_prod.request_quantity += qosl_with_same_supply.delivered_quantity 
                else
                  int_ord_prod.request_quantity = 0
                  int_ord_prod.request_quantity += qosl_with_same_supply.delivered_quantity
                end
                if qosl_with_same_supply.provider_observation.present?; int_ord_prod.provider_observation = qosl_with_same_supply.provider_observation; end
                if qosl_with_same_supply.applicant_observation.present?; int_ord_prod.applicant_observation = qosl_with_same_supply.applicant_observation; end
                int_ord_prod.created_at = qosl_with_same_supply.created_at
                int_ord_prod.updated_at = qosl_with_same_supply.updated_at
    
                if qosl_with_same_supply.sector_supply_lot_id.present? && LotStock.where(id: qosl_with_same_supply.sector_supply_lot_id).present?
                  int_ord_prod.order_prod_lot_stocks.build(
                    lot_stock_id: qosl_with_same_supply.sector_supply_lot_id,
                    quantity: qosl_with_same_supply.delivered_quantity,
                    created_at: qosl_with_same_supply.created_at,
                    updated_at: qosl_with_same_supply.updated_at
                  )
                else
                  int_ord_prod.delivery_quantity -= qosl_with_same_supply.delivered_quantity 
                end
              end
            end
          end
        end
        if new_internal_order.internal_order_products.size > 0
          new_internal_order.save!
        end
      end
    end
  end
end