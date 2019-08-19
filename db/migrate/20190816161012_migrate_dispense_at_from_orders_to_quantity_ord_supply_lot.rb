class MigrateDispenseAtFromOrdersToQuantityOrdSupplyLot < ActiveRecord::Migration[5.2]
  def change
    Prescription.find_each do |pre|
      if pre.dispensed_at.present?
        pre.quantity_ord_supply_lots.each do |qosl| 
          qosl.dispensed_at = pre.dispensed_at
          qosl.save!
        end
      end
    end
    InternalOrder.find_each do |int|
      if int.sent_date.present?
        int.quantity_ord_supply_lots.each do |qosl|
          qosl.dispensed_at = int.sent_date
          qosl.save!
        end
      end
    end
    OrderingSupply.find_each do |ord|
      if ord.sent_date.present?
        ord.quantity_ord_supply_lots.each do |qosl| 
          qosl.dispensed_at = ord.sent_date
          qosl.save!
        end
      end
    end
  end
end
