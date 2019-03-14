class CreateBeds < ActiveRecord::Migration[5.2]
  def change
    create_table :beds do |t|
      t.string :name
      t.references :bedroom, index: true

      t.timestamps
    end
  end
end
