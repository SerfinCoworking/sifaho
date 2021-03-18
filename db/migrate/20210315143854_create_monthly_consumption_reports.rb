class CreateMonthlyConsumptionReports < ActiveRecord::Migration[5.2]
  def change
    create_table :monthly_consumption_reports do |t|
      t.integer :report_type, default: 0
      t.references :product, index: true
      t.references :created_by, index: true
      t.references :sector, index: true
      t.datetime :since_date
      t.datetime :to_date

      t.timestamps
    end
  end
end
