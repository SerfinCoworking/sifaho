class FixDuplicatedSelectedLotsOnChronicPrescriptionProducts < ActiveRecord::Migration[5.2]
  def up
    
    ChronicPrescription.where(status: [:pendiente, :dispensada_parcial]).each do |chronic_pres|
      chronic_pres.chronic_dispensations.each do |cd|
        cd.chronic_prescription_products.each do |cpp|
          # obtenemos los id de los productos
          all_cpp_ids = cpp.order_prod_lot_stocks.pluck(:lot_stock_id)
          # filtramos los ids, solo los que se repiten
          reapeted_cpp_ids = all_cpp_ids.select{ |e| all_cpp_ids.count(e) > 1}
          if reapeted_cpp_ids.count > 0
            puts "Receta a Actualizar: #{chronic_pres.id.to_s}".colorize(:green)
            reapeted_cpp_ids.uniq.each do |target_product| 

              @origin_opls = cpp.order_prod_lot_stocks.where(lot_stock_id: target_product).first
            
              # Buscamos todos los productos, y excluimos a @org_product
              @other_opls = cpp.order_prod_lot_stocks.where(lot_stock_id: target_product).where.not(id: @origin_opls.id)

              @other_opls.each do |opls|
                puts "Order Product Lot Stock repetido #{opls.id}".colorize(:blue)
                # Primero actualizamos la cantidad dispensada en el original product
                update_opls_quantity(@origin_opls, opls)
                
                puts "Order Product Lot Stock eliminado #{opls.id}".colorize(:blue)
                opls.destroy
              end
            end
          end
        end
      end
    end

  end

  def down
  end

  private
  def update_opls_quantity(origin_opls, opls)
    origin_opls.quantity += opls.quantity
    origin_opls.save(validate: false)
    puts "--Cantidad total entregada: #{origin_opls.quantity}".colorize(background: :green)
  end

end
