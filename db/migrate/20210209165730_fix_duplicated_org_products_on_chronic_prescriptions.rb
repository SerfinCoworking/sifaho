class FixDuplicatedOrgProductsOnChronicPrescriptions < ActiveRecord::Migration[5.2]
  def up
    # Buscamos las prescripciones que aun estan pendientes o parcialmente dispensadas
    ChronicPrescription.where(status: [:pendiente, :dispensada_parcial]).each do |chronic_pres|

      # obtenemos los id de los productos
      all_original_products = chronic_pres.original_chronic_prescription_products.pluck(:product_id)
      # filtramos los ids, solo los que se repiten
      reapeted_product_ids = all_original_products.select{ |e| all_original_products.count(e) > 1}
      
      if reapeted_product_ids.count > 0
        
        puts "Receta a Actualizar: #{chronic_pres.id.to_s}".colorize(:green)
        # por cada repetido "unico" realizamos el proceso correspondiente
        reapeted_product_ids.uniq.each do |target_product| 
          # obtenemos el primer original product ordenados por request_quantityuest_quantity (nos quedamos con el que mayor cantidad a dispensar tiene)
          
          @org_product = chronic_pres.original_chronic_prescription_products.where(product_id: target_product).order(:request_quantity).first
          
          # Buscamos todos los productos, y excluimos a @org_product
          @org_product_to_destroy = chronic_pres.original_chronic_prescription_products.where(product_id: target_product).where.not(id: @org_product.id)

          # Por cada original product a eliminar encontrado, vamos a obtener el total_delivered_quantity y sus relaciones
          @org_product_to_destroy.each do |org_prod_to_destroy|
            puts "Producto original repetido #{org_prod_to_destroy.id}".colorize(:blue)
            # Primero actualizamos la cantidad dispensada en el original product
            org_product_total_delivered_quantity(@org_product, org_prod_to_destroy)
          
            # Actualizamos los productos registrados, con el id del produco original que va a quedar.
            update_chronic_prescription_products(@org_product, org_prod_to_destroy)
              
            # Tercero, y finalmente eliminamos el registro duplicado
            puts "Original Chronic Prescription Product eliminado: " + org_prod_to_destroy.id.to_s.colorize(:red)
            org_prod_to_destroy.destroy
          end 
        end
      end
    end
  end
  
  def down
  end

  private
  def org_product_total_delivered_quantity(org, org_to_del)
    org.total_delivered_quantity += org_to_del.total_delivered_quantity
    org.save(validate: false)
    puts "Cantidad total entregada actualizada: #{org.total_delivered_quantity}".colorize(background: :green)
  end
  
  def update_chronic_prescription_products(org, org_to_del)
    org_to_del.chronic_prescription_products.each do |cpp|
      cpp.original_chronic_prescription_product_id = org.id
      cpp.save(validate: false)
      puts "Chronic Prescription Product actualizado: #{cpp.id}".colorize(background: :green)
    end
  end

end
