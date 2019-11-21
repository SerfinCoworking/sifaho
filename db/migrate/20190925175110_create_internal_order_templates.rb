class CreateInternalOrderTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :internal_order_templates do |t|
      t.string :name
      t.references :owner_sector, index: true
      t.references :detination_sector, index: true
      t.references :created_by, index: true
      t.integer :order_type, default: 0
      t.text :observation

      t.timestamps
    end
  end
end
