class MigrateQuantityOrdSupplyLotOrderingSupplyToExternalOrder < ActiveRecord::Migration[5.2]
  def change
    QuantityOrdSupplyLot.find_each do |qosl|
      if qosl.quantifiable_type == "OrderingSupply"
        qosl.quantifiable_type = "ExternalOrder"
      end
      qosl.save(validate: false)
    end
  end
end
