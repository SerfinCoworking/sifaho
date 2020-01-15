class ReplicateSupplyAreasToAreas < ActiveRecord::Migration[5.2]
  def change
    add_reference :products, :area, foreign_key: true
    SupplyArea.find_each do |sup_area|
      Area.create!(name: sup_area.name)
    end
  end
end
