class CreateReports < ActiveRecord::Migration[5.2]
  def change
    create_table :reports do |t|
      t.string :name, default: "Reporte"
      t.datetime :since_date
      t.datetime :to_date
      t.integer :report_type, default: 0
      t.references :supply, foreign_key: true
      t.references :sector, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
