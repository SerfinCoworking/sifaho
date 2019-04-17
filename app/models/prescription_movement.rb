class PrescriptionMovement < ApplicationRecord
  belongs_to :user
  belongs_to :prescription
  belongs_to :sector
end
