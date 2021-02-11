class FixChronicPrescriptionProductsWithoutLotSelection < ActiveRecord::Migration[5.2]
  def up
    ChronicPrescription.where(status: [:pendiente, :dispensada_parcial]).each do |chronic_pres|
      chronic_pres.chronic_dispensations.each do |cd|
        cd.chronic_prescription_products.each do |cpp|
          if cpp.order_prod_lot_stocks.count == 0
            puts "Se elimina Chronic Prescription Product: #{cpp.id}".colorize(:red)
            cpp.destroy
          end
        end
      end
    end
  end

  def down
    
  end
end
