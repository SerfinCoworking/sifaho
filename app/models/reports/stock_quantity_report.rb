class StockQuantityReport < ApplicationRecord
  belongs_to :created_by, class_name: 'User'
  belongs_to :sector
  has_many :stock_report_areas
  has_many :supply_areas, through: :stock_report_areas
end
