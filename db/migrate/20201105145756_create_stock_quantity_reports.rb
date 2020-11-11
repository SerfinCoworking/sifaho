class CreateStockQuantityReports < ActiveRecord::Migration[5.2]
  def change
    create_table :stock_quantity_reports do |t|
      t.references :created_by, index: true
      t.references :sector, index: true

      t.timestamps
    end
  end
end
