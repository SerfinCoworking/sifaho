class ExternalOrderProductReport < ApplicationRecord
  include Reportable

  # Relationships
  belongs_to :created_by, class_name: 'User'
  belongs_to :sector

  # Delegations
  delegate :establishment_name, to: :sector

  # Validations
  validates_presence_of :since_date, :to_date
end
