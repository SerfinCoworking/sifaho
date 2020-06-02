##########################
laboratoryOne = Laboratory.create!(
  :cuit => "123456789",
  :gln => "123456789",
  :name => "laboratorio 1"
)
##########################
supplyArea = SupplyArea.create!(
  :name => "area's name"
)
##########################
supplyOne = Supply.create!(
  :name => "suply name",
  :description => "a short description",
  :observation => "a short observation",
  :unity => "1",
  :quantity_alarm => 2,
  :period_control => 2,
  :supply_area_id => supplyArea.id
)
###########################
supplyLotsInf = SupplyLot.create!(
  :code => "codigo",
  :expiry_date => DateTime.now(),
  :date_received => DateTime.now(),
  :quantity => 20,
  :initial_quantity => 60,
  :supply_id => supplyOne.id,
  :lot_code => "10",
  :laboratory_id => laboratoryOne.id
)
##########################
areaName = Area.create!(
  :name => "area's name"
)
##########################
productExample = Product.create!(
  :unity => Unity.first ,
  :code => "code producr",
  :name => "name product",
  :area => areaName
)
##########################
#sector Informatica 
sectorInf = Sector.where(name: "Informática").first
##########################
stocks = Stock.create!(
  :sector => sectorInf,
  :product => productExample,
  :quantity => 20
)
##########################
# sector Informatica sector_supply_lots
inf_sector_supply_lots = SectorSupplyLot.create(
  :sector => sectorInf,
  :supply_lot => supplyLotsInf,
  :quantity => 5
)


