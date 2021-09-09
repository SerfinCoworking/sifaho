class MonthlyConsumptionReport < ApplicationRecord

  enum report_type: { un_producto: 0, por_rubro: 1 }

  # Relationships
  belongs_to :created_by, class_name: 'User'
  belongs_to :sector
  belongs_to :product, optional: true
  has_many :monthly_consumption_areas
  has_many :areas, through: :monthly_consumption_areas

  # Validations
  validates_presence_of :sector, :since_date, :to_date, :report_type
  validates_presence_of :product_id, :product, if: Proc.new { |report| report.un_producto? }
  validates :areas, presence: true, if: Proc.new { |report| report.por_rubro? }

  # Delegations
  delegate :code, :name, :area_name, to: :product, prefix: true
end