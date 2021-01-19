class MigrateSupplyLotsToLots < ActiveRecord::Migration[5.2]
  def change
    SupplyLot.find_each do |supply_lot|
      Lot.create(
        id: supply_lot.id,
        code: supply_lot.lot_code,
        product_id: Product.where(code: supply_lot.supply_id).first.id,
        expiry_date: supply_lot.expiry_date,
        laboratory_id: supply_lot.laboratory_id,
        status: supply_lot.status
      )
    end
  end
end
