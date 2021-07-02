class MigrateOriginalChronicPrescriptionProducts < ActiveRecord::Migration[5.2]
  def change
    OriginalChronicPrescriptionProduct.all.find_each do |product|
      unless product.terminado_manual?
        if product.total_request_quantity <= product.total_delivered_quantity
          puts "Original product id: #{product.id}, estado: #{product.treatment_status}"
          product.treatment_status = 'terminado'
        else
          product.treatment_status = 'pendiente'
        end
        product.save(validate: false)
      end
    end
  end
end
