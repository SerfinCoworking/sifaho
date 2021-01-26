class CreatePurchaseMovements < ActiveRecord::Migration[5.2]
  def change
    create_table :purchase_movements do |t|
      t.references :purchase, index: true
      t.references :user, index: true
      t.references :sector, index: true
      t.string :action
      t.timestamps
    end
  end
end
