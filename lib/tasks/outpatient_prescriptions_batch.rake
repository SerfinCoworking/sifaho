namespace :batch do
  desc 'Migrate outpatient prescriptions'
  task migrate_outpatient_prescriptions: :environment do
    Prescription.ambulatoria.each do |old_prescription|
      puts "Receta ambulatoria id: "+old_prescription.id.to_s

      if old_prescription.quantity_ord_supply_lots.present?

        new_prescription = OutpatientPrescription.new(
          id: old_prescription.id,
          professional_id: old_prescription.professional_id,
          patient_id: old_prescription.patient_id,
          provider_sector_id: old_prescription.provider_sector_id,
          establishment_id: old_prescription.establishment_id,
          remit_code: old_prescription.remit_code,
          observation: old_prescription.observation,
          date_prescribed: old_prescription.prescribed_date,
          expiry_date: old_prescription.expiry_date,
          status: old_prescription.status
        )

        old_prescription.quantity_ord_supply_lots.each do |qosl|
          product_id = Product.where(code: qosl.supply_id).first.id

          if qosl.sector_supply_lot_id.present? && LotStock.where(id: qosl.sector_supply_lot_id).present?

            # Check if the product was already created
            if new_prescription.outpatient_prescription_products.to_ary.select { |opp| opp.product_id == product_id }.size == 0
              out_pre_prod = new_prescription.outpatient_prescription_products.build
              out_pre_prod.product_id = product_id

              old_prescription.quantity_ord_supply_lots.where(supply_id: qosl.supply_id).each do |qosl_with_same_supply|
                if out_pre_prod.delivery_quantity.present?
                  out_pre_prod.delivery_quantity += qosl_with_same_supply.delivered_quantity
                else
                  out_pre_prod.delivery_quantity = 0
                  out_pre_prod.delivery_quantity += qosl_with_same_supply.delivered_quantity
                end
                if out_pre_prod.request_quantity.present?
                  out_pre_prod.request_quantity += qosl_with_same_supply.delivered_quantity
                else
                  out_pre_prod.request_quantity = 0
                  out_pre_prod.request_quantity += qosl_with_same_supply.delivered_quantity
                end
                if qosl_with_same_supply.provider_observation.present?; out_pre_prod.observation = qosl_with_same_supply.provider_observation; end
                out_pre_prod.created_at = qosl_with_same_supply.created_at
                out_pre_prod.updated_at = qosl_with_same_supply.updated_at
    
                if qosl_with_same_supply.sector_supply_lot_id.present? && LotStock.where(id: qosl_with_same_supply.sector_supply_lot_id).present?
                  out_pre_prod.order_prod_lot_stocks.build(
                    lot_stock_id: qosl_with_same_supply.sector_supply_lot_id,
                    quantity: qosl_with_same_supply.delivered_quantity,
                    created_at: qosl_with_same_supply.created_at,
                    updated_at: qosl_with_same_supply.updated_at
                  )
                else
                  out_pre_prod.delivery_quantity -= qosl_with_same_supply.delivered_quantity 
                end
              end
            end # End if has repeated supplies
          end # End if sector supply lot present
        end
        if new_prescription.outpatient_prescription_products.size > 0
          new_prescription.save!
        end
      end
    end
  end
end