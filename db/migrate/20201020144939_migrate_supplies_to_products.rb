class MigrateSuppliesToProducts < ActiveRecord::Migration[5.2]
  def change
    Product.destroy_all

    Supply.find_each do |supply|
      Product.create(
        code: supply.id,
        name: supply.name,
        description: supply.description,
        observation: supply.observation,
        area_id: supply.supply_area_id,
        unity_id: Unity.where(name: supply.unity).first.present? ? Unity.where(name: supply.unity).first.id : 55
      )
    end
  end
end
