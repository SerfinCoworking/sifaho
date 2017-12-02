class CreateSectors < ActiveRecord::Migration[5.1]
  def change
    create_table :sectors do |t|
      t.string :sector_name
      t.text :description
      t.integer :level_complexity
      t.string :applicant

      t.timestamps
    end
  end
end
