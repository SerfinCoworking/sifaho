class CreateInternalOrderProductReports < ActiveRecord::Migration[5.2]
  def change
    create_table :internal_order_product_reports do |t|
      t.references :created_by, index: true
      t.date :since_date
      t.date :to_date
      t.references :product, index: true
      t.references :supply, index: true
      t.references :sector, index: true

      t.timestamps
    end
  end
end
