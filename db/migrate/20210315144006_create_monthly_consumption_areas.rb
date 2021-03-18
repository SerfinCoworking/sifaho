class CreateMonthlyConsumptionAreas < ActiveRecord::Migration[5.2]
  def change
    create_table :monthly_consumption_areas do |t|
      t.references :monthly_consumption_report, index: {name: :monthly_consumption_area}
      t.references :area, index: true

      t.timestamps
    end
  end
end
