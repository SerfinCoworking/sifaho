class CreatePurchaseAreas < ActiveRecord::Migration[5.2]
  def change
    create_table :purchase_areas do |t|
      t.references :purchase, index: true
      t.references :area, index: true
    end
  end
end
