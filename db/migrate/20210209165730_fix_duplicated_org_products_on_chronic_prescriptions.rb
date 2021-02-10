class FixDuplicatedOrgProductsOnChronicPrescriptions < ActiveRecord::Migration[5.2]
  def up
    # Buscamos las prescripciones que aun estan pendientes o parcialmente dispensadas
    ChronicPrescription.where(status: [:pendiente, :dispensada_parcial]).limit(50).each do |chronic_pres|

      # obtenemos los id de los productos
      all_original_products = chronic_pres.original_chronic_prescription_products.select(:product_id).pluck(:product_id)
      # filtramos los ids, solo los que se repiten
      reapeted_product_ids = all_original_products.select{ |e| all_original_products.count(e) > 1}
      
      if reapeted_product_ids.count > 0
       puts chronic_pres.id.to_s
        # obtenemos el primer ord product de los id repetidos (haciendo un uniq) 
        # ordenados por request_quantity (nos quedamos con el que mayor cantidad a dispensar tiene)
        @org_product = chronic_pres.original_chronic_prescription_products.where(product_id: reapeted_product_ids.uniq).order(:request_quantity).first
        
        @org_product_to_destroy = chronic_pres.original_chronic_prescription_products.where(product_id: reapeted_product_ids.uniq).order(:request_quantity).where.not(id: @org_product.id)

        @org_product_to_destroy.each do |org_prod_to_destroy|
          # Primero actualizamos la cantidad dispensada en el original product
          @org_product.total_delivered_quantity += org_prod_to_destroy.total_delivered_quantity
          @org_product.save(validate: false)
          
          # Segundo debemos actualizar las relaciones de org_prod_to_destroy
          org_prod_to_destroy.chronic_prescription_products.each do |cpp|
            cpp.original_chronic_prescription_product_id = @org_product.id
            cpp.save(validate: false)
          end
          # Tercero, y finalmente eliminamos el registro duplicado
          puts "Original Chronic Prescription Product eliminado: " + org_prod_to_destroy.id.to_s.colorize(:red)
          org_prod_to_destroy.destroy
        end
      end
     
    end
  end
  
  def down
  end
end
