class MigrateSuppliesToProducts < ActiveRecord::Migration[5.2]
  def change
    Supply.find_each do |supply|
      Product.create!(
        code: supply.id,
        name: supply.name,
        description: supply.description,
        observation: supply.observation,
        area_id: Area.where(name: supply.supply_area.name).first.present? ? Area.where(name: supply.supply_area.name).first.id : 1,
        unity_id: Unity.where(name: supply.unity).first.present? ? Unity.where(name: supply.unity).first.id : 55
      )
    end
  end
end
