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
  :supply_area_id => supplyArea.id,
  :is_active => true
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

##########################
Supply.create!(
  :name => "suply name 2",
  :description => "a short description 2",
  :observation => "a short observation 2",
  :unity => "10",
  :quantity_alarm => 2,
  :period_control => 2,
  :supply_area_id => supplyArea.id,
  :is_active => true
)
##########################
Supply.create!(
  :name => "suply name 3",
  :description => "a short description 3",
  :observation => "a short observation 3",
  :unity => "30",
  :quantity_alarm => 3,
  :period_control => 3,
  :supply_area_id => supplyArea.id,
  :is_active => true
)
##########################
Supply.create!(
  :name => "suply name 4",
  :description => "a short description 4",
  :observation => "a short observation 4",
  :unity => "6",
  :quantity_alarm => 4,
  :period_control => 4,
  :supply_area_id => supplyArea.id,
  :is_active => true
)