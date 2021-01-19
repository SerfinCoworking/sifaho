class ChangeQuantifiableTypeFromQuantityOrdSupplyLots < ActiveRecord::Migration[5.2]
  def change
    QuantityOrdSupplyLot.where(quantifiable_type: 'ExternalOrder').find_each do |qosl|
      qosl.quantifiable_type = 'ExternalOrderBak'
      qosl.save
    end
    QuantityOrdSupplyLot.where(quantifiable_type: 'InternalOrder').find_each do |qosl|
      qosl.quantifiable_type = 'InternalOrderBak'
      qosl.save
    end
  end
end