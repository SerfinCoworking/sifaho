class ExternalOrderProductReport < ApplicationRecord
  belongs_to :created_by, class_name: 'User'
  belongs_to :product, optional: true
  belongs_to :supply
  belongs_to :sector

  delegate :name, to: :supply, prefix: true
  delegate :establishment_name, to: :sector

  validates_presence_of :supply_id, :since_date, :to_date
end
