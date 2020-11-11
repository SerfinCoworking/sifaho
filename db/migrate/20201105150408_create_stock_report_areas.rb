class CreateStockReportAreas < ActiveRecord::Migration[5.2]
  def change
    create_table :stock_report_areas do |t|
      t.references :stock_quantity_report, index: true
      t.references :area, index: true
      t.references :supply_area, index: true

      t.timestamps
    end
  end
end
