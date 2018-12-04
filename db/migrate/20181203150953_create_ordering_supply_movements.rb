class CreateOrderingSupplyMovements < ActiveRecord::Migration[5.1]
  def change
    create_table :ordering_supply_movements do |t|
      t.references :user, index: true
      t.references :ordering_supply, index: true
      t.references :sector, index: true
      t.string :action

      t.timestamps
    end
  end
end
