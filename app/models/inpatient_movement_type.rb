class InpatientMovementType < ApplicationRecord

  # Relationships
  has_many :inpatient_movements

  # Validations
  validates :name, presence: true
end
