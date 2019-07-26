class CreateOrderingSupplyComments < ActiveRecord::Migration[5.2]
  def change
    create_table :ordering_supply_comments do |t|
      t.references :ordering_supply, foreign_key: true
      t.references :user, foreign_key: true
      t.text :text

      t.timestamps
    end
  end
end
