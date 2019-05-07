class AddCronicDispensationToQuantityOrdSupplyLot < ActiveRecord::Migration[5.2]
  def change
    add_reference :quantity_ord_supply_lots, :cronic_dispensation, index: true
  end
end
