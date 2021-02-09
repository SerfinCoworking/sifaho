class FixDuplicatedOrgProductsOnChronicPrescriptions < ActiveRecord::Migration[5.2]
  def up
    # Buscamos las prescripciones que aun estan pendientes o parcialmente dispensadas
    ChronicPrescription.where(status: [:pendiente, :dispensada_parcial]).each do |chronic_pres|
      chronic_pres.original_chronic_prescription_products.each do |ocpp|
        # Buscamos los productos originales que esten repetidos en la receta
        appearances = chronic_pres.original_chronic_prescription_products.where(product_id: ocpp.product_id)

        if appearances.count > 1
          # Si hay coincidencias procemos a unificar el total dispensado y cambiar la relacion de los productos dispensados
          # para que apunte a solo un original
          puts "Receta Crónica: #{chronic_pres.id.to_s} tiene #{appearances.count.to_s.colorize(:red)} coincidencias"
          original = appearances.order(:request_quantity).first
          appearances.each do |appearance|
            appearance.chronic_prescription_products.each do |cpp|
              cpp.original_chronic_prescription_product_id = original.id
              puts "Se actualiza la relación con Original [#{cpp.id.to_s}]".colorize(:blue)
              cpp.save(validate: false)
              if original.id != appearance.id
                original.total_delivered_quantity += appearance.total_delivered_quantity
                original.save(validate: false)
                puts "Se actualizó la cantiad dispensada de Original: #{original.id.to_s} / cantitdad: #{original.total_delivered_quantity}".colorize(:blue)
                puts "Se elimina Producto Original: #{appearance.id.to_s}".colorize(:red)
                appearance.destroy

              end
            end
          end
        end
      end

    end
  end
  
  def down
  end
end
