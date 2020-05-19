class CreateExternalOrderTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :external_order_templates do |t|
      t.string :name
      t.references :owner_sector, index: true
      t.references :destination_establishment, index: true
      t.references :destination_sector, index: true
      t.references :created_by, index: true
      t.integer :order_type, default: 0
      t.text :observation

      t.timestamps
    end
  end
end
