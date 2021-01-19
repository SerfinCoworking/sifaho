class MigrateSectorSupplyLots < ActiveRecord::Migration[5.2]
  def change
    SectorSupplyLot.find_each do |sector_lot|
      stock = Stock.where(
        sector_id: sector_lot.sector_id,
        product_id: Product.where(code: sector_lot.supply_lot.supply_id).first.id
      ).first_or_create
      LotStock.create(
        id: sector_lot.id,
        lot_id: sector_lot.supply_lot_id,
        stock_id: stock.id,
        quantity: sector_lot.quantity
      )
    end
  end
end