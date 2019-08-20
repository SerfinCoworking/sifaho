class MigrateOrderingSupplyStatusToQuantityOrdSupplyLots < ActiveRecord::Migration[5.2]
  def change
    OrderingSupply.find_each do |ord|
      if ord.provision_en_camino? || ord.provision_entregada?
        ord.quantity_ord_supply_lots.each do |qosl|
          qosl.dispensed_at = ord.sent_date
          qosl.entregado!
        end
      end
    end
    InternalOrder.find_each do |int_ord|
      if int_ord.provision_en_camino? || int_ord.provision_entregada?
        int_ord.quantity_ord_supply_lots.each do |qosl|
          qosl.dispensed_at = int_ord.sent_date
          qosl.entregado!
        end
      end
    end
  end
end
