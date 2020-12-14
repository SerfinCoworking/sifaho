class ChronicPrescriptionMovement < ApplicationRecord
  belongs_to :user
  belongs_to :chronic_prescription
  belongs_to :sector
end
