namespace :batch do
  desc 'Migrate chronic prescriptions'
  task migrate_chronic_prescriptions: :environment do
    Prescription.cronica.last(100).each do |old_prescription|
      puts "Receta crónica id: "+old_prescription.id.to_s

      if old_prescription.quantity_ord_supply_lots.present?

        new_prescription = ChronicPrescription.new(
          id: old_prescription.id,
          professional_id: old_prescription.professional_id,
          patient_id: old_prescription.patient_id,
          provider_sector_id: old_prescription.provider_sector_id,
          establishment_id: old_prescription.establishment_id,
          remit_code: old_prescription.remit_code,
          diagnostic: old_prescription.observation,
          date_prescribed: old_prescription.prescribed_date,
          expiry_date: old_prescription.prescribed_date + (old_prescription.times_dispensation.present? ? old_prescription.times_dispensation.month : 6),
          status: old_prescription.status
        )
        # Create original chronic prescriptions products
        puts "Estado de receta: "+old_prescription.status
        if (old_prescription.dispensada_parcial? || old_prescription.dispensada?) && old_prescription.cronic_dispensations.count > 0
          puts "Entró creacion"
          puts "Cantidad de dispensaciones: "+old_prescription.cronic_dispensations.count.to_s
          old_prescription.cronic_dispensations.first.quantity_ord_supply_lots.each do |qosl|
            product_id = Product.where(code: qosl.supply_id).first.id
            new_prescription.original_chronic_prescription_products.build(
              product_id: product_id,
              request_quantity: qosl.requested_quantity,
              total_request_quantity: qosl.requested_quantity * old_prescription.times_dispensation,
              total_delivered_quantity: old_prescription.quantity_ord_supply_lots.where(supply_id: qosl.supply_id).where.not(sector_supply_lot_id: nil).sum(:delivered_quantity)
            )
          end
          
          new_prescription.save!

          old_prescription.cronic_dispensations.each do |cronic_dispensation|
            # Create ChronicDispensation
            new_chronic_dispensation = new_prescription.chronic_dispensations.build
            new_chronic_dispensation.created_at = cronic_dispensation.created_at
            new_chronic_dispensation.updated_at = cronic_dispensation.updated_at
            if old_prescription.times_dispensation == old_prescription.times_dispensed
              new_chronic_dispensation.status = 'dispensada'
            elsif cronic_dispensation == old_prescription.cronic_dispensations.last
              new_chronic_dispensation.status = 'pendiente'
            else
              new_chronic_dispensation.status = 'dispensada'
            end


            cronic_dispensation.quantity_ord_supply_lots.each do |qosl|
              product_id = Product.where(code: qosl.supply_id).first.id
            
              if qosl.sector_supply_lot_id.present? && LotStock.where(id: qosl.sector_supply_lot_id).present?
                puts "Entró if qosl sector present"
                # Check if the product was already created
                if new_chronic_dispensation.chronic_prescription_products.to_ary.select { |opp| opp.product_id == product_id }.size == 0
                  puts "entró chronic prescription products"
                  cron_pre_prod = new_chronic_dispensation.chronic_prescription_products.build
                  cron_pre_prod.product_id = product_id
                  
                  cronic_dispensation.quantity_ord_supply_lots.where(supply_id: qosl.supply_id).each do |qosl_with_same_supply|
                    if cron_pre_prod.delivery_quantity.present?
                      cron_pre_prod.delivery_quantity += qosl_with_same_supply.delivered_quantity
                    else
                      cron_pre_prod.delivery_quantity = 0
                      cron_pre_prod.delivery_quantity += qosl_with_same_supply.delivered_quantity
                    end
                    if qosl_with_same_supply.provider_observation.present?; cron_pre_prod.observation = qosl_with_same_supply.provider_observation; end
                    cron_pre_prod.created_at = qosl_with_same_supply.created_at
                    cron_pre_prod.updated_at = qosl_with_same_supply.updated_at
        
                    if qosl_with_same_supply.sector_supply_lot_id.present? && LotStock.where(id: qosl_with_same_supply.sector_supply_lot_id).present?
                      cron_pre_prod.order_prod_lot_stocks.build(
                        lot_stock_id: qosl_with_same_supply.sector_supply_lot_id,
                        quantity: qosl_with_same_supply.delivered_quantity,
                        created_at: qosl_with_same_supply.created_at,
                        updated_at: qosl_with_same_supply.updated_at
                      )
                    else
                      cron_pre_prod.delivery_quantity -= qosl_with_same_supply.delivered_quantity 
                    end
                  end
                end # End if has repeated supplies
              end # End if sector supply lot present
            end
          end
        elsif old_prescription.pendiente?
          old_prescription.quantity_ord_supply_lots.each do |qosl|
            product_id = Product.where(code: qosl.supply_id).first.id
            new_prescription.original_chronic_prescription_products.build(
              product_id: product_id,
              request_quantity: qosl.requested_quantity,
              total_request_quantity: qosl.requested_quantity * (old_prescription.times_dispensation.present? ? old_prescription.times_dispensation : 6),
              total_delivered_quantity: old_prescription.quantity_ord_supply_lots.where(supply_id: qosl.supply_id).where.not(sector_supply_lot_id: nil).sum(:delivered_quantity)
            )
          end
        end

        puts "Cantidad de productos: "+new_prescription.chronic_prescription_products.size.to_s
        if new_prescription.chronic_prescription_products.size > 0 || new_prescription.original_chronic_prescription_products.size > 0
          if new_prescription.save!
            new_prescription.original_chronic_prescription_products.each do |original_product|
            end
          end
        end
      end
    end
  end
end