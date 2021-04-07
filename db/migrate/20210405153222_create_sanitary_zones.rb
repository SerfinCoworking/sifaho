class CreateSanitaryZones < ActiveRecord::Migration[5.2]
  def change
    create_table :sanitary_zones do |t|
      t.string :name
      t.references :state, index: true

      t.timestamps
    end
  end
end
