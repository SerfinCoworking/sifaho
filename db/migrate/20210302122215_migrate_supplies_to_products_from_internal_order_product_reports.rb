class MigrateSuppliesToProductsFromInternalOrderProductReports < ActiveRecord::Migration[5.2]
  def change
    InternalOrderProductReport.find_each do |report|
      product = Product.find_by_code(report.supply_id)
      report.product_id = product.id
      report.save
    end
  end
end
