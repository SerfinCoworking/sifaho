class UpdateChronicDispensationWithDispensationTypes < ActiveRecord::Migration[5.2]
  def up
    ChronicPrescription.all.limit(10).each do |cp|
      cp.chronic_dispensations.each do |cd|
        # Buscamos los id de los productos recetados (puede que esten repetidos)
        all_ocpp_ids = ChronicPrescriptionProduct.where(chronic_dispensation_id: cd.id).pluck(:original_chronic_prescription_product_id)

        # Creamos un "DispensationType" (agrupado por orginal_chronic_prescription_product_id)
        all_ocpp_ids.uniq.each do |target_product|
        
          # Obtenemos la dosis entregada:
          # Antes de esta migración todo se estaba dispensado por dosis, por lo tanto no debes sumar las cantidad
          # asignadas por cada lote / producto
          quantity = OriginalChronicPrescriptionProduct.find(target_product).request_quantity

          @dt = DispensationType.new(
            chronic_dispensation_id:  cd.id,
            original_chronic_prescription_product_id:  target_product,
            quantity: quantity,
            created_at: cd.created_at,
            updated_at: cd.updated_at
          )  
          @dt.save!(validate: false)

          ChronicPrescriptionProduct.where(chronic_dispensation_id: cd.id, original_chronic_prescription_product_id: target_product).each do |cpp|
            cpp.dispensation_type_id = @dt.id
            cpp.save!(validate: false)
          end
          puts "Se creo DispensationType para OCCP #{target_product}".colorize(background: :green)
        end

      end
    end

    puts "Se actualizaron #{ChronicPrescription.all.limit(10).count} prescripciones cronicas".colorize(background: :blue)
  end

  def down
  end
end
