class FixDuplicatedOrgProductsOnChronicPrescriptions < ActiveRecord::Migration[5.2]
  def up
    # Buscamos las prescripciones que aun estan pendientes o parcialmente dispensadas
    ChronicPrescription.where(status: [:pendiente, :dispensada_parcial]).each do |chronic_pres|

      # obtenemos los id de los productos
      all_ocpp_ids = chronic_pres.original_chronic_prescription_products.pluck(:product_id)
      # filtramos los ids, solo los que se repiten
      reapeted_ocpp_ids = all_ocpp_ids.select{ |e| all_ocpp_ids.count(e) > 1}
      
      if reapeted_ocpp_ids.count > 0
        
        puts "Receta a Actualizar: #{chronic_pres.id.to_s}".colorize(:green)
        # por cada repetido "unico" realizamos el proceso correspondiente
        reapeted_ocpp_ids.uniq.each do |target| 
          # obtenemos el primer original product ordenados por request_quantityuest_quantity (nos quedamos con el que mayor cantidad a dispensar tiene)
          
          @ocpp = chronic_pres.original_chronic_prescription_products.where(product_id: target).order(:request_quantity).first
          
          # Buscamos todos los productos, y excluimos a @ocpp
          @ocpp_to_destroy = chronic_pres.original_chronic_prescription_products.where(product_id: target).where.not(id: @ocpp.id)

          # Por cada original product a eliminar encontrado, vamos a obtener el total_delivered_quantity y sus relaciones
          @ocpp_to_destroy.each do |occp_to_destroy|
            puts "Producto original repetido #{occp_to_destroy.id}".colorize(:blue)
            # Primero actualizamos la cantidad dispensada en el original product
            update_ocpp_total_delivered_quantity(@ocpp, occp_to_destroy)
          
            # Actualizamos los productos registrados, con el id del produco original que va a quedar.
            update_cpp_with_occp_relationship(@ocpp, occp_to_destroy)
              
            # Tercero, y finalmente eliminamos el registro duplicado
            puts "Original Chronic Prescription Product eliminado: " + occp_to_destroy.id.to_s.colorize(:red)
            occp_to_destroy.destroy
          end 
        end
      end
    end
  end
  
  def down
  end

  private
  def update_ocpp_total_delivered_quantity(ocpp, ocpp)
    ocpp.total_delivered_quantity += ocpp.total_delivered_quantity
    ocpp.save(validate: false)
    puts "Cantidad total entregada actualizada: #{ocpp.total_delivered_quantity}".colorize(background: :green)
  end
  
  def updcpp_with_occp_relationship(ocpp, ocpp)
    ocpp.chronic_prescription_products.each do |cpp|
      cpp.original_chronic_prescription_product_id = ocpp.id
      cpp.save(validate: false)
      puts "Chronic Prescription Product actualizado: #{cpp.id}".colorize(background: :green)
    end
  end

end
