class InternalOrderProductReport < ApplicationRecord
  include Reportable

  belongs_to :created_by, class_name: 'User'
  belongs_to :product, optional: true
  belongs_to :supply, optional: true
  belongs_to :sector

  delegate :name, to: :supply, prefix: true
  delegate :name, to: :product, prefix: :product
  delegate :establishment_name, to: :sector

  validates_presence_of :since_date, :to_date, :created_by
end
