require 'colorize'

namespace :batch do
  desc 'Migrate chronic prescriptions'
  task migrate_chronic_prescriptions: :environment do
    Prescription.cronica.where.not(times_dispensation: nil).each do |old_prescription|
      puts "Receta crónica id: #{+old_prescription.id.to_s}".light_blue

      # si tiene almenos 1 producto asociado creamos la receta
      if old_prescription.quantity_ord_supply_lots.present? && old_prescription.quantity_ord_supply_lots.count > 0

        #1 Se crea la receta
        new_prescription = ChronicPrescription.create!(
          id: old_prescription.id,
          professional_id: old_prescription.professional_id,
          patient_id: old_prescription.patient_id,
          provider_sector_id: old_prescription.provider_sector_id,
          establishment_id: old_prescription.establishment_id,
          remit_code: old_prescription.remit_code,
          diagnostic: old_prescription.observation,
          date_prescribed: old_prescription.prescribed_date,
          expiry_date: old_prescription.prescribed_date + (old_prescription.times_dispensation.present? ? old_prescription.times_dispensation.month : 6),
          status: 'pendiente'
        )

        
        puts "Se creó la receta sin productos: #{new_prescription.id.to_s} (Old prescription id)".green
        
        # Create original chronic prescriptions products
        #2 Se agregan los productos originales a la receta
        # Como no existia esta tabla, se crea a partir de cada producto diferente asociado atraves de quantityOrdSupplyLot
        old_prescription.quantity_ord_supply_lots.select(:supply_id, :requested_quantity).distinct.each do |qosl|
          product_id = Product.where(code: qosl.supply_id).first.id
          puts "=======> Se crea el producto original: " + qosl.supply_id.to_s.colorize(:red).colorize( :background => :green) + " " + old_prescription.id.to_s
          OriginalChronicPrescriptionProduct.create!(
            chronic_prescription_id: new_prescription.id,
            product_id: product_id,
            request_quantity: qosl.requested_quantity,
            total_request_quantity: qosl.requested_quantity * old_prescription.times_dispensation,
            total_delivered_quantity: 0
          )
        end
        
        puts "Se crearon y asociaron los productos originales a la receta: #{new_prescription.original_chronic_prescription_products.count} (productos)".green

        if (old_prescription.dispensada_parcial? || old_prescription.dispensada?) 
       
          #3 Se agregan las dispensaciones
          old_prescription.cronic_dispensations.distinct(:created_at).each_with_index do |cronic_dispensation, index|
            # Create ChronicDispensation
            if cronic_dispensation.quantity_ord_supply_lots.count > 0
              chronic_dispensation = ChronicDispensation.create!(
                chronic_prescription_id: new_prescription.id,
                created_at: cronic_dispensation.created_at,
                updated_at: cronic_dispensation.updated_at,
                status: 'dispensada'
              )

              new_prescription.dispensada_parcial!

              puts "Se creó la Dispensación n°: ".green + (index + 1).to_s.colorize(:white).colorize( :background => :blue)
              #4 Se agregan los productos dispensados a cada dispensacion
              cronic_dispensation.quantity_ord_supply_lots.each do |qosl|
                product_id = Product.where(code: qosl.supply_id).first.id
              
                #5 Checkeo de LotStock
                if qosl.sector_supply_lot_id.present?
                  
                  # Si no existe el LotStock, no se crea el producto
                  @lot_stock = LotStock.where(id: qosl.sector_supply_lot.id).first
                  if @lot_stock.present?
                    # Las dipensaciones de las recetas cronicas pueden tener mas de un producto asignado
                    # en ese caso, de los productos asignados a la dispensacion le asignamos solo el lote seleccionado
                    # evitando duplicar el producto
                    chronic_prescription_product = chronic_dispensation.chronic_prescription_products.find_by(product_id: product_id)
                    puts "ChronicPrescriptionProduct #{chronic_prescription_product} / product ID #{product_id}".yellow
                    if chronic_prescription_product.present?
                      # debemos incrementar el delivery_quantity
                      chronic_prescription_product.delivery_quantity += qosl.delivered_quantity
                      chronic_prescription_product.save!
                      puts "Incrementamos el delivery_quantity: " + chronic_prescription_product.delivery_quantity.to_s.colorize(:light_blue).colorize( :background => :green)
                    else
                      # Se crea ChronicPrescriptionProduct, la cantidad inicial es la misma que la de qosl.quantity
                      original_chronic_prescription_product = new_prescription.original_chronic_prescription_products.find_by(product_id: product_id)
                      puts "OriginalChronicPrescriptionProduct #{original_chronic_prescription_product.id} / product id #{product_id}".green
                      
                      chronic_prescription_product = ChronicPrescriptionProduct.create!(
                        product_id: product_id,
                        original_chronic_prescription_product_id: original_chronic_prescription_product.id,
                        chronic_dispensation_id: chronic_dispensation.id,
                        delivery_quantity: qosl.delivered_quantity,
                        observation: qosl.provider_observation,
                        created_at: qosl.created_at,
                        updated_at: qosl.updated_at
                      )
                    end

                    # Se crea el ChronPresProdLotStock
                    ChronPresProdLotStock.create(
                      chronic_prescription_product_id: chronic_prescription_product.id,
                      lot_stock_id: @lot_stock.id,
                      quantity: qosl.delivered_quantity,
                      created_at: qosl.created_at,
                      updated_at: qosl.updated_at
                    )
                    puts "Se creó ChronPresProdLotStock".green
                  elsif
                    puts "QOSL no posee LotStock o el Lote: #{qosl.supply_id.to_s} (product id) / LotStock: #{qosl.sector_supply_lot_id.to_s} / Lote: #{qosl.supply_lot_id.to_s}".red
                    
                  end # End if sector supply lot present
                elsif
                  puts "No se encontró el LotStock con id: #{qosl.sector_supply_lot_id.to_s}".red
                end
              end


            elsif
              puts "===> No se creó disp: Receta #{old_prescription.id} / Dispensación #{chronic_dispensation.id} porque tiene #{chronic_dispensation.quantity_ord_supply_lots.count.to_s} productos asignados".red
            end
          
          end
        end
        
        # Se actualiza el total dispensado de la receta
        new_prescription_status_dispensada = false
        new_prescription.original_chronic_prescription_products.each do |original_product|
          original_product.total_delivered_quantity = new_prescription.chronic_prescription_products.where(product_id: original_product.product_id).joins(:chronic_dispensation).where("chronic_dispensations.status = 1").sum(:delivery_quantity)  
          original_product.save!
        end

        if new_prescription.original_chronic_prescription_products.sum(:total_request_quantity) <= new_prescription.original_chronic_prescription_products.sum(:total_delivered_quantity)
          new_prescription.dispensada!
        end

        # Se crean todos los movimientos de ChronicPrescription
        old_prescription.movements.each do |movement|
          ChronicPrescriptionMovement.create!(
            user_id: movement.user_id,
            chronic_prescription_id: new_prescription.id,
            sector_id: movement.sector_id,
            action: movement.action,
            created_at: movement.created_at,
            updated_at: movement.updated_at
          )
        end

        # Creación de movimientos del stock
        if new_prescription.persisted?
          if new_prescription.dispensada_parcial? || new_prescription.dispensada?
            new_prescription.chronic_prescription_products.each do |chron_pre_product|
              chron_pre_product.order_prod_lot_stocks.each do |opls|
                # Movimiento de baja para proveedor con fecha de dispensación "updated_at"
                StockMovement.create!(
                  stock: opls.lot_stock.stock,
                  order: new_prescription,
                  lot_stock: opls.lot_stock,
                  quantity: opls.quantity,
                  adds: false,
                  created_at: opls.updated_at,
                  updated_at: opls.updated_at
                )
              end
            end
          end
        end # End if en camino || entregada
      elsif
        puts "====> No se creó la receta cuyo id: #{old_prescription.id} porque tiene #{old_prescription.quantity_ord_supply_lots.count} productos asociados".colorize(:light_blue).colorize( :background => :red)
      end

      puts "Se migraron #{ChronicPrescription.count.to_s} de #{Prescription.cronica.count.to_s} recetas crónicas".colorize(:white).colorize( :background => :green)
    end
  end
end