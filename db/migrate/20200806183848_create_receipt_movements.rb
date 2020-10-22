class CreateReceiptMovements < ActiveRecord::Migration[5.2]
  def change
    create_table :receipt_movements do |t|
      t.references :user, index: true
      t.references :receipt, index: true
      t.references :sector, index: true
      t.string :action

      t.timestamps
    end
  end
end
