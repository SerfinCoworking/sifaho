class CreateSupplyAreas < ActiveRecord::Migration[5.1]
  def change
    create_table :supply_areas do |t|
      t.string :name, :limit => 50
    end
  end
end
