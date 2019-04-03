class CreateBedOrderMovements < ActiveRecord::Migration[5.2]
  def change
    create_table :bed_order_movements do |t|
      t.references :user, index: true
      t.references :bed_order, index: true
      t.references :sector, index: true
      t.string :action

      t.timestamps
    end
  end
end
