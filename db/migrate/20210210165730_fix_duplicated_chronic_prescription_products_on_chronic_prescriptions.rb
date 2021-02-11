
class FixDuplicatedChronicPrescriptionProductsOnChronicPrescriptions < ActiveRecord::Migration[5.2]
  def up
    # En una migracion anteriro se corrgieron los original_chronic_prescription_products repetidos
    # En esta migracion vamos a unificar los productos duplicados posterior a la migracion anterior donde se removieron
    # los productos originales recetados duplicados


    # Buscamos las prescripciones que aun estan pendientes o parcialmente dispensadas
    ChronicPrescription.where(status: [:pendiente, :dispensada_parcial]).each do |chronic_pres|

      chronic_pres.chronic_dispensations.each do |cd|
        

        # obtenemos los id de los productos
        all_ocpp_ids = cd.chronic_prescription_products.pluck(:original_chronic_prescription_product_id)
        # filtramos los ids, solo los que se repiten
        reapeted_ocpp_ids = all_ocpp_ids.select{ |e| all_ocpp_ids.count(e) > 1}
      

        if reapeted_ocpp_ids.count > 0
          
          puts "Receta a Actualizar: #{chronic_pres.id.to_s}".colorize(:green)
          
          # por cada repetido "unico" realizamos el proceso correspondiente
          reapeted_ocpp_ids.uniq.each do |target_product| 
            # obtenemos el primer product
            
            @cpp = cd.chronic_prescription_products.where(original_chronic_prescription_product_id: target_product).first
            
            # Buscamos todos los productos, y excluimos a @cpp
            @cpp_to_destroy = cd.chronic_prescription_products.where(original_chronic_prescription_product_id: target_product).where.not(id: @cpp.id)

            # Por cada original product a eliminar encontrado, vamos a obtener el total_delivered_quantity y sus relaciones
            @cpp_to_destroy.each do |cpp_to_destroy|
              puts "Chronic Prescription Product repetido #{cpp_to_destroy.id}".colorize(:blue) + " Actualizar a: #{@cpp.id}".colorize(background: :green)
              # Primero actualizamos la cantidad dispensada en el original product
              update_cpp_delivery_quantity(@cpp, cpp_to_destroy)
            
              # Actualizamos los lotes seleccionados por producto
              update_opls_with_cpp_relationship(@cpp, cpp_to_destroy)

              puts "----Cantidad entregada actualizada: #{@cpp.delivery_quantity}"
            end 
          end
        end
      end
    end
  end
  
  def down
  end

  private
  def update_cpp_delivery_quantity(cpp, cpp_to_destroy)
    cpp.delivery_quantity += cpp_to_destroy.delivery_quantity
    cpp.save(validate: false)
    puts "--Cantidad total entregada actualizada: #{cpp.delivery_quantity}".colorize(background: :green)
  end


  def update_opls_with_cpp_relationship(cpp, cpp_to_destroy)

    cpp_to_destroy.order_prod_lot_stocks.each do |opls|
      puts "--Order_prod_lot_stock actualizado: #{opls.id.to_s}".colorize(background: :blue)
      opls.chronic_prescription_product_id = cpp.id
      opls.save(validate: false)
    end
  end
end
