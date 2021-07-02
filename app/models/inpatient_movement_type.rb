class InpatientMovementType < ApplicationRecord

  # Relationships
  has_many :inpatient_movements, foreign_key: :movement_type

  # Validations
  validates :name, presence: true
end
