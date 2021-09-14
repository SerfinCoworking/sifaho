class OutpatientPrescriptionMovement < ApplicationRecord
  
  # Relationships
  belongs_to :user
  belongs_to :outpatient_prescription
  belongs_to :sector
end
