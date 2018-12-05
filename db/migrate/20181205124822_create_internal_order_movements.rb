class CreateInternalOrderMovements < ActiveRecord::Migration[5.1]
  def change
    create_table :internal_order_movements do |t|
      t.references :user, index: true
      t.references :internal_order, index: true
      t.references :sector, index: true
      t.string :action

      t.timestamps
    end
  end
end
