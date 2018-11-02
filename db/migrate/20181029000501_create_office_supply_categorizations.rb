class CreateOfficeSupplyCategorizations < ActiveRecord::Migration[5.1]
  def change
    create_table :office_supply_categorizations do |t|
      t.references :office_supply, index: true
      t.references :category, index: true
      t.integer :position

      t.timestamps
    end
  end
end
