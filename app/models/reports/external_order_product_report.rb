class ExternalOrderProductReport < ApplicationRecord
  belongs_to :created_by, class_name: 'User'
  belongs_to :product, optional: true
  belongs_to :sector

  delegate :name, to: :product, prefix: true
  delegate :establishment_name, to: :sector

  validates_presence_of :product_id, :since_date, :to_date
end
