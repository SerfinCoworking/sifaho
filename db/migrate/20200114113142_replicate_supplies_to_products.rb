class ReplicateSuppliesToProducts < ActiveRecord::Migration[5.2]
  def change
    Supply.find_each do |supply|
      Product.create!(name: supply.name, code: supply.id, unity: Unity.find_by_name(supply.unity), area: Area.find_by_name(supply.supply_area.name))
    end
  end
end
