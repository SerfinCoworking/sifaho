class OutpatientPrescriptionMovement < ApplicationRecord
  belongs_to :user
  belongs_to :outpatient_prescription
  belongs_to :sector
end
