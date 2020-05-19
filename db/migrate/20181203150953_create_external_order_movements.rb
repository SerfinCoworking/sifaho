class CreateExternalOrderMovements < ActiveRecord::Migration[5.1]
  def change
    create_table :external_order_movements do |t|
      t.references :user, index: true
      t.references :external_order, index: true
      t.references :sector, index: true
      t.string :action

      t.timestamps
    end
  end
end
