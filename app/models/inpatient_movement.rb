class InpatientMovement < ApplicationRecord
  
  # Relationships
  belongs_to :bed
  belongs_to :patient
  belongs_to :movement_type
  belongs_to :user

  # Validations
  validates :bed, :patient, :movement_type, :user, :observations, presence: true

  before_validation :assign_description
end
