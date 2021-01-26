class CreatePurchaseComments < ActiveRecord::Migration[5.2]
  def change
    create_table :purchase_comments do |t|
      t.references :purchase, index: true
      t.references :user, index: true
      t.text :text
      t.timestamps
    end
  end
end
