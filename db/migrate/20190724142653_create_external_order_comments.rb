class CreateExternalOrderComments < ActiveRecord::Migration[5.2]
  def change
    create_table :external_order_comments do |t|
      t.references :external_order, index: true
      t.references :user, index: true
      t.text :text

      t.timestamps
    end
  end
end
