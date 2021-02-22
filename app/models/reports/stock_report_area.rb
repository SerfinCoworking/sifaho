class StockReportArea < ApplicationRecord
  belongs_to :stock_quantity_report
  belongs_to :area
  belongs_to :supply_area, optional: true

  validates_presence_of :area
end
