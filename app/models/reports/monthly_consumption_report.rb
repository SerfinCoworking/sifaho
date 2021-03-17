class MonthlyConsumptionReport < ApplicationRecord
  enum report_type: { producto: 0, rubro: 1 }
  belongs_to :created_by, class_name: 'User'
  belongs_to :sector
  belongs_to :product, optional: true
  has_many :monthly_consumption_areas
  has_many :areas, through: :monthly_consumption_areas

  validates_presence_of :sector, :since_date, :to_date, :report_type
  validates_presence_of :product_id, :product, if: Proc.new { |report| report.producto? }
  validates :areas, presence: true, if: Proc.new { |report| report.rubro? }

  delegate :code, :name, to: :product, prefix: true
end
