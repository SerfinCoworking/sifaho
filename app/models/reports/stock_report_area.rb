class StockReportArea < ApplicationRecord
  belongs_to :stock_quantity_report
  belongs_to :area, optional: true
  belongs_to :supply_area

  validates_presence_of :supply_area
end
