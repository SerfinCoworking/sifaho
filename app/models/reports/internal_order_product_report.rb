class InternalOrderProductReport < ApplicationRecord
  include Reportable

  # Relationships
  belongs_to :created_by, class_name: 'User'
  belongs_to :product, optional: true
  belongs_to :supply, optional: true
  belongs_to :sector

  # Delegations
  delegate :name, to: :supply, prefix: true
  delegate :name, to: :product, prefix: :product
  delegate :establishment_name, to: :sector

  # Validations
  validates_presence_of :since_date, :to_date, :created_by
end
