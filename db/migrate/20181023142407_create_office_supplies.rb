class CreateOfficeSupplies < ActiveRecord::Migration[5.1]
  def change
    create_table :office_supplies do |t|
      t.string :name
      t.text :description
      t.integer :quantity
      t.integer :status, default: 0
      t.references :sector, index: true

      t.timestamps
    end
  end
end
