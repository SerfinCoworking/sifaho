##########################
# laboratoryOne = Laboratory.create!(
#   :cuit => "123456789",
#   :gln => "123456789",
#   :name => "laboratorio 1"
# )
###########################
# supplyLotsInf = SupplyLot.create!(
#   :code => "ABCD",
#   :expiry_date => DateTime.now(),
#   :date_received => DateTime.now(),
#   :quantity => 20,
#   :initial_quantity => 60,
#   :supply_id => supplyOne.id,
#   :lot_code => "10",
#   :laboratory_id => laboratoryOne.id
# )
##########################
#sector Informatica 
# sectorInf = Sector.where(name: "Informática").first
##########################

##########################
# sector Informatica sector_supply_lots
# inf_sector_supply_lots = SectorSupplyLot.create(
#   :sector => sectorInf,
#   :supply_lot => supplyLotsInf,
#   :quantity => 5
# )