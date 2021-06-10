class MigrateOriginalChronicPrescriptionProducts < ActiveRecord::Migration[5.2]
  def change
    OriginalChronicPrescriptionProduct.all.find_each do |product|
      unless product.terminado_manual?
        if product.total_delivered_quantity <= product.total_request_quantity
          puts "Original product id: #{product.id}, estado: #{product.treatment_status}"
          product.treatment_status = 'terminado'
          product.save(validate: false)
        end
      end
    end
  end
end
