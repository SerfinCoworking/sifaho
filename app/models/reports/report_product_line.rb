class ReportProductLine < ApplicationRecord
  # Relationships
  belongs_to :reportable, polymorphic: true
  belongs_to :product

  # Delegations
  delegate :name, :code, to: :product, prefix: :product
end
