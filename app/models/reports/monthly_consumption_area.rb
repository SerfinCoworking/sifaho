class MonthlyConsumptionArea < ApplicationRecord
  belongs_to :monthly_consumption_report
  belongs_to :area
end
