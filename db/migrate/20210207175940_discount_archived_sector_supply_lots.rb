class DiscountArchivedSectorSupplyLots < ActiveRecord::Migration[5.2]
  def change
    SectorSupplyLot.archivado.each do |sector_supply_lot|

      stock = Stock.where(
        sector_id: sector_supply_lot.sector_id,
        product_id: Product.where(code: sector_supply_lot.supply_lot.supply_id).first.id
      ).first
      puts "Stock id: "+stock.id.to_s.colorize(:light_blue).on_green
      
      lot_stock = LotStock.where(
        id: sector_supply_lot.id,
        lot_id: sector_supply_lot.supply_lot_id,
        stock_id: stock.id,
        quantity: sector_supply_lot.quantity
      ).first

      # If predent decrement archived quantity to lot stock
      if lot_stock.present?
        puts "Lot stock presente id: "+lot_stock.id.to_s.colorize(:green).on_blue
        puts "Cantidad actual: "+lot_stock.quantity.to_s.colorize(:blue).on_green
        lot_stock.decrement(sector_supply_lot.quantity)
        puts "Cantidad despues: "+lot_stock.quantity.to_s.colorize(:blue).on_red
      end
    end
  end
end