class PatientProductReport < ApplicationRecord
  include Reportable

  # Relationships
  belongs_to :created_by, class_name: 'User'
  belongs_to :product, optional: true
  belongs_to :sector

  # Delegations
  delegate :code, :name, to: :product, prefix: :product

  # Validations
  validates_presence_of :since_date, :to_date, :created_by, :sector
end
