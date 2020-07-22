class CreateInternalOrderComments < ActiveRecord::Migration[5.2]
  def change
    create_table :internal_order_comments do |t|
      t.references :order, index: true
      t.references :user, index: true
      t.text :text

      t.timestamps
    end
  end
end
