class CreateReportProductLines < ActiveRecord::Migration[5.2]
  def change
    create_table :report_product_lines do |t|
      t.references :reportable, polymorphic: true, index: true
      t.references :product, foreign_key: true

      t.timestamps
    end
  end
end
